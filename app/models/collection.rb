# A subclass of {Item} that has a matrix of Sample ids and does not belong to a {SampleType}

class Collection < Item

  EMPTY = -1 # definition of empty

  # CLASS METHODS ###################################################################


  def self.every
    Item.joins(:object_type).where(object_types: { handler: "collection" })
  end

  def self.containing s, ot=nil
    return [] unless s
    i = s.id.to_s
    r = Regexp.new '\[' + i + ',|,' + i + ',|,' + i + '\]|\[' + i + '\]'
    if ot
      Collection.includes(:object_type).where(object_type_id: ot.id)
                .select { |i| r =~ i.datum[:matrix].to_json  }
    else
      Collection.every.select { |i| r =~ i.datum[:matrix].to_json }
    end
  end

  # Returns first Array element from #find
  # 
  # @see #find
  def position s
    self.find(s).first
  end

  def position_as_hash s
    pos = self.find self.to_sample_id(s)
    { row: pos.first[0], column: pos.first[1] }
  end  

  def self.parts s, ot=nil
    plist = []
    Collection.containing(s,ot).reject { |c| c.deleted? }.each do |c|
      plist << Collection.find(c.id).position_as_hash(s).merge(collection: c)
    end
    return plist
  end

  def self.spread samples, name, options={}
    opts = { reverse: false }.merge(options)
    remaining = samples
    collections = []
    while remaining.any?
      c = self.new_collection name
      old_size = remaining.size
      remaining = c.add_samples(remaining, opts)
      if old_size <= remaining.size
        raise "There was an error adding samples #{samples.map { |s| self.to_sample_id(s) }} to collection of type #{name}"
      end
      collections << c
    end
    collections
  end

  # METHODS #########################################################################


  def self.new_collection name

    o = ObjectType.find_by_name(name)
    raise "Could not find object type named '#{name}'." unless o

    i = Collection.new
    i.object_type_id = o.id
    i.apportion(o.rows, o.columns)
    i.quantity = 1
    i.inuse = 0
    i.location = "Bench"
    i.save
    i

  end

  # Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database.
  # Whatever matrix was associated with the collection is lost
  # 
  # @param r [Integer] Row
  # @param c [Integer] Column
  def apportion r, c
    self.matrix = (Array.new(r,Array.new(c,EMPTY)))
  end

  # Whether the matrix includes x
  #
  # @param x [Fixnum, Sample, Item]
  # @return [Boolean]
  def include? x
    sel = self.find x
    sel.any?
  end

  # Finds rows, cols in which block is true
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def select
    raise "need selection block" unless block_given?
    self.matrix.map.with_index do |row, r|
      cols_where = row.each_index.select { |i| Proc.new.call(row[i]) }
      cols_where.map { |c| [r, c] }
    end.select { |d| d.any? }.flatten(1)
  end

  # Finds rows, cols that equal val
  #
  # @param val [Fixnum, Sample, Item]
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def find val
    self.select { |x| x == self.to_sample_id(val) }
  end

  # Gets all empty rows, cols
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def get_empty
    self.select { |x| x == EMPTY }
  end

  # Gets all non-empty rows, cols
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def get_non_empty
    self.select { |x| x != EMPTY }
  end

  # Returns the number of non empty slots in the matrix
  #
  # @return [Fixnum]
  def num_samples
    get_non_empty.size
  end

  # Changes Item, String, or Sample to a sample.id for storing into a collection matrix. Maybe should be private
  #
  # class method?
  def to_sample_id x
    r = EMPTY
    case
      when x.class == Fixnum
        r = x
      when x.class == Item
        if x.sample
          r = x.sample.id
        else
          raise "When the third argument to Collection.set is an item, it should be associated with a sample."
        end
      when x.class == Sample
        r = x.id
      when x.class == String
        r = x.split(':')[0].to_i
      when !x
        r = EMPTY
      else
        raise "The third argument to Collection.set should be an item, a sample, or a sample id, but it was '#{x}' which is a #{x.class}"
    end
    r
  end

  # Adds sample, item, or number to collection
  #
  # @param x [Fixnum, Sample, Item]
  # @param options [Hash]
  # @option options [Bool] :reverse Start from end of matrix
  # @example
  #   c = Collection.find_by_id(1)
  #   c.matrix # [[-1, -1, 3], [4, -1, -1]]
  #   c.add_one(777)
  #   c.matrix
  #     [ [777, -1, 3],
  #       [4, -1, -1] ]
  #   c.add_one(888)
  #     [ [777, 888, 3],
  #       [4, -1, -1] ]
  #   c.add_one(999, reverse: true)
  #     [ [777, 888, 3],
  #       [4, -1, 999] ]
  def add_one x, options={}
    opts = { reverse: false }.merge(options)
    r, c = [nil, nil]
    if opts[:reverse]
      r, c = self.get_empty.last
    else
      r, c = self.get_empty.first
    end
    if r.nil? or c.nil?
      return nil
    end
    self.set r, c, x
    [r, c, x]
  end

  # @see #subtract_one
  def remove_one x=nil, options={}
    self.subtract_one(x, options)
  end

  # Find last [r,c] that equals x and sets to EMPTY. If x.nil? then it finds the last non_empty slot. If reverse: false
  # then finds the first [r,c] equal to x. Returns [r,c,sample_at_rc] if x is in collection. or nil if x is not found or the col.empty?
  #
  # @param x [Fixnum, Sample, Item]
  # @param options [Hash]
  # @option options [Bool] :reverse Begin from the end of the matrix
  def subtract_one x=nil, options={}
    opts = { reverse: true }.merge(options)
    r, c = [nil, nil]
    sel = self.get_non_empty
    sel = self.find x if not x.nil?
    if sel.empty?
      return nil
    end
    if opts[:reverse]
      r,c = sel.last
    else
      r,c = sel.first
    end
    s = self.matrix[r][c]
    self.set r, c, EMPTY
    [r, c, s]
  end

  def capacity
    d = self.dimensions
    d[0] * d[1]
  end

  # Whether the matrix has no EMPTY slots
  #
  # @return [Bool]
  def full?
    self.get_empty.empty?
  end

  # Whether the matrix is empty
  #
  # @return [Bool]
  def empty?
    self.get_non_empty.empty?
  end

  # Set the [r,c] entry of the matrix to id of the Sample s. If s=nil, then the [r,c] entry is cleared
  #
  # @param r [Integer] Row
  # @param c [Integer] Column
  # @param x [Fixnum, Sample, Item]
  def set r, c, x
    m = self.matrix
    d = self.dimensions
    if r >= d[0] or c >= d[1]
      raise "Set matrix error: Indices #{r},#{c} greater than allowed for matrix dimensions #{d[0]}x#{d[1]}"
    end
    m[r][c] = self.to_sample_id(x)
    self.matrix = m
    self.save
  end

  # Fill collecion with samples
  # Return samples that were not filled
  def add_samples samples, options={}
    opts = { reverse: false }.merge(options)
    non_empty_arr = self.get_empty
    non_empty_arr.reverse! if opts[:reverse]
    remaining = []
    samples.zip(non_empty_arr).each do |s, rc|
      if rc.nil?
        remaining << s
      else
        r, c = rc
        set r, c, s
      end
    end
    remaining
  end

  # Sets the matrix associated with the collection to the matrix m where m can be either a matrix of Samples or
  # a matrix of sample ids. Only sample ids are saved to the matrix. Whatever matrix was associated with the collection is lost
  #
  # @param sample_matrix [Array<Array<Sample>>, Array<Array<Fixnum>>]
  def associate sample_matrix

    m = self.get_data[:matrix]

    (0..sample_matrix.length-1).each do |r|
      (0..sample_matrix[r].length-1).each do |c|
        if sample_matrix[r][c].class == Sample
          m[r][c] = sample_matrix[r][c].id
        else
          m[r][c] = sample_matrix[r][c]
        end
      end
    end

    self.matrix = m

  end

  # @see #associate
  def set_matrix m
    self.associate m
  end

  def get_matrix
    self.datum[:matrix]
  end

  # Return matrix of {Sample} ids
  #
  # @return [Array<Array<Integer>>]
  def matrix
    self.datum[:matrix]
  end

  # Set the matrix associated with the collection to the matrix of Sample ids m. Whatever matrix was associated with the collection is lost
  def matrix= m
    d = self.datum
    self.datum = d.merge( { matrix: m } )
  end

  # With no options, returns the indices of the next element of the collections, skipping to the next column or row if necessary.
  # With the option skip_non_empty: true, returns the next non empty indices. Returns nil if [r,c] is the last element of the collection
  #
  # @param r [Integer] Row
  # @param c [Integer] Column
  # @param options [Hash]
  # @option options [Bool] :skip_non_empty Return next non-empty indices
  def next r, c, options={}

    opts = { skip_non_empty: false }.merge options

    m = self.matrix
    nr, nc = self.dimensions

    (r..nr-1).each do |row|
      (0..nc-1).each do |col|
        if row > r || col > c
          if !opts[:skip_non_empty] || m[row][col] == EMPTY
            return [ row, col ]
          end
        end
      end
    end

    return [nil,nil]

  end

  # Returns the dimensions of the matrix associated with the collection
  #
  # @return [Array<Fixnum>]
  def dimensions
    m = self.matrix
    if m && m[0]
      [ m.length, m[0].length ]
    else
      [ 0, 0 ]
    end
  end

  # Returns a string describing the indices of the non empty elements in the collection. For example,
  # the method might return the string "1,1 - 5,9" to indicate that collection contains samples in
  # those indices. Note that the string is adjusted for viewing by the user, so starts with 1 instead of 0 for rows and columns
  #
  # @return [String]
  def non_empty_string

    m = self.matrix
    max = [0,0]

    (0..m.length-1).each do |r|
      (0..m[r].length-1).each do |c|
        if m[r][c] != EMPTY
          max = [r,c]
        end
      end
    end

    if m.length > 1
      "1,1 - #{max[0]+1}, #{max[1]+1}"
    else
      "1 - #{max[1]+1}"
    end

  end

end
