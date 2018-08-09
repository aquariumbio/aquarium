

# A subclass of {Item} that has a matrix of Sample ids and does not belong to a {SampleType}
# @api krill
class Collection < Item

  EMPTY = -1 # definition of empty

  def self.every
    Item.joins(:object_type).where(object_types: { handler: 'collection' })
  end

  def self.containing(s, ot = nil)
    return [] unless s
    i = s.id.to_s
    r = Regexp.new '\[' + i + ',|,' + i + ',|,' + i + '\]|\[' + i + '\]'
    if ot
      Collection.includes(:object_type).where(object_type_id: ot.id)
                .select { |i| r =~ i.datum[:matrix].to_json }
    else
      Collection.every.select { |i| r =~ i.datum[:matrix].to_json }
    end
  end

  # Returns first Array element from #find
  #
  # @see #find
  def position(s)
    find(s).first
  end

  def position_as_hash(s)
    pos = find to_sample_id(s)
    { row: pos.first[0], column: pos.first[1] }
  end

  def self.parts(s, ot = nil)
    plist = []
    Collection.containing(s, ot).reject(&:deleted?).each do |c|
      plist << Collection.find(c.id).position_as_hash(s).merge(collection: c)
    end
    plist
  end

  # Creates as many new collections of type `name` 
  # as will be necessary to hold every sample in the
  # `samples` list. 
  # 
  # @param samples [Array<Sample>]  list of samples to initiate collections with
  # @param name [String]  the name of a valid collection object type that will be
  #               created and populated with samples
  # @return [Array<Collection>]  list of newly created collections of type `name`
  #                     that hold all given `samples`.  No more collections will be
  #                     created than are needed to hold all the samples
  def self.spread(samples, name, options = {})
    opts = { reverse: false }.merge(options)
    remaining = samples
    collections = []
    while remaining.any?
      c = new_collection name
      old_size = remaining.size
      remaining = c.add_samples(remaining, opts)
      raise "There was an error adding samples #{samples.map { |s| to_sample_id(s) }} to collection of type #{name}" if old_size <= remaining.size
      collections << c
    end
    collections
  end

  # Make an entirely new collection.
  # 
  # @param name [String]  the name of the valid collection object type to make a collection with
  # @return [Collection]  new empty collection of type `name`
  def self.new_collection(name)

    o = ObjectType.find_by_name(name)
    raise "Could not find object type named '#{name}'." unless o

    i = Collection.new
    i.object_type_id = o.id
    i.apportion(o.rows, o.columns)
    i.quantity = 1
    i.inuse = 0

    if o
      i.object_type_id = o.id
      wiz = Wizard.find_by_name(o.prefix)
      locator = wiz.next if wiz
      i.set_primitive_location locator.to_s if wiz
    end

    if locator
      ActiveRecord::Base.transaction do
        i.save
        locator.item_id = i.id
        locator.save
        i.locator_id = locator.id
        i.save
        locator.save
      end
    else
      i.location = 'Bench'
      i.save
    end

    i
  end

  # Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database,
  # whatever matrix was associated with the collection is lost.
  #
  # @param r [Integer] row
  # @param c [Integer] column
  def apportion(r, c)
    self.matrix = Array.new(r, Array.new(c, EMPTY))
  end

  # Informs whether the matrix includes x.
  #
  # @param x [Fixnum, Sample, Item]
  # @return [Boolean]
  def include?(x)
    sel = find x
    sel.any?
  end

  # Finds parts of collection in which block is true.
  #
  # @return [Array<Array<Fixnum>>]  selected parts in the form [[r1, c1], [r2, c2]]
  def select
    raise 'need selection block' unless block_given?
    matrix.map.with_index do |row, r|
      cols_where = row.each_index.select { |i| Proc.new.call(row[i]) }
      cols_where.map { |c| [r, c] }
    end.select(&:any?).flatten(1)
  end

  # Finds parts that equal val.
  #
  # @param val [Fixnum, Sample, Item]
  # @return [Array<Array<Fixnum>>] selected parts in the form [[r1, c1], [r2, c2]]
  def find(val)
    select { |x| x == to_sample_id(val) }
  end

  # Gets all empty rows, cols.
  #
  # @return [Array<Array<Fixnum>>] empty parts in the form [[r1, c1], [r2, c2]]
  def get_empty
    select { |x| x == EMPTY }
  end

  # Gets all non-empty rows, cols.
  #
  # @return [Array<Array<Fixnum>>] non-empty parts in the form [[r1, c1], [r2, c2]]
  def get_non_empty
    select { |x| x != EMPTY }
  end

  # Returns the number of non empty slots in the matrix.
  #
  # @return [Fixnum]
  def num_samples
    get_non_empty.size
  end

  # Changes Item, String, or Sample to a sample.id for storing into a collection matrix. 
  #
  def to_sample_id(x)
    # class method?
    #Maybe should be private
    r = EMPTY
    if x.class == Integer || x.class == Fixnum # Not sure where "Integer" came from here ---ek
      r = x
    elsif x.class == Item
      if x.sample
        r = x.sample.id
      else
        raise 'When the third argument to Collection.set is an item, it should be associated with a sample.'
      end
    elsif x.class == Sample
      r = x.id
    elsif x.class == String
      r = x.split(':')[0].to_i
    elsif !x
      r = EMPTY
    else
      raise "The third argument to Collection.set should be an item, a sample, or a sample id, but it was '#{x}' which is a #{x.class}"
    end
    r
  end

  # Adds sample, item, or number to collection.
  #
  # @param x [Fixnum, Sample, Item]
  # @param options [Hash]
  # @option options [Bool] :reverse start from end of matrix
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
  def add_one(x, options = {})
    opts = { reverse: false }.merge(options)
    r = nil
    c = nil
    if opts[:reverse]
      r, c = get_empty.last
    else
      r, c = get_empty.first
    end
    return nil if r.nil? || c.nil?
    set r, c, x
    [r, c, x]
  end

  # @see #subtract_one
  def remove_one(x = nil, options = {})
    subtract_one(x, options)
  end

  # Find last [r,c] that equals x and sets to EMPTY. If x.nil? then it finds the last non_empty slot. If reverse: false
  # then finds the first [r,c] equal to x. Returns [r,c,sample_at_rc] if x is in collection, or nil if 
  # x is not found or the collection is empty.
  #
  # @param x [Fixnum, Sample, Item]
  # @param options [Hash]
  # @option options [Bool] :reverse begin from the end of the matrix
  def subtract_one(x = nil, options = {})
    opts = { reverse: true }.merge(options)
    r = nil
    c = nil
    sel = get_non_empty
    sel = find x unless x.nil?
    return nil if sel.empty?
    if opts[:reverse]
      r, c = sel.last
    else
      r, c = sel.first
    end
    s = matrix[r][c]
    set r, c, EMPTY
    [r, c, s]
  end

  def capacity
    d = dimensions
    d[0] * d[1]
  end

  # Whether the matrix has no EMPTY slots.
  #
  # @return [Bool]
  def full?
    get_empty.empty?
  end

  # Whether the matrix is empty.
  #
  # @return [Bool]
  delegate :empty?, to: :get_non_empty

  # Set the [r,c] entry of the matrix to id of the Sample s. If s=nil, then the [r,c] entry is cleared.
  #
  # @param r [Integer]  row
  # @param c [Integer]  column
  # @param x [Fixnum, Sample, Item]  new sample for that row
  def set(r, c, x)
    m = matrix
    d = dimensions
    raise "Set matrix error: Indices #{r},#{c} greater than allowed for matrix dimensions #{d[0]}x#{d[1]}" if (r >= d[0]) || (c >= d[1])
    m[r][c] = to_sample_id(x)
    self.matrix = m
    save
  end

  # Fill collecion with samples.
  #
  # @param [Array<Sample>]  samples to put in collection
  # @return [Array<Sample>]  samples that were not filled
  def add_samples(samples, options = {})
    opts = { reverse: false }.merge(options)
    non_empty_arr = get_empty
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
  # a matrix of sample ids. Only sample ids are saved to the matrix. Whatever matrix was associated with the collection is lost.
  #
  # @param sample_matrix [Array<Array<Sample>>, Array<Array<Fixnum>>]
  def associate(sample_matrix)
    # TODO remove this method so that collections can inherit DataAssociator associate
    # matrix=() does everything just fine and has a more informative method name
    m = get_data[:matrix]

    (0..sample_matrix.length - 1).each do |r|
      (0..sample_matrix[r].length - 1).each do |c|
        m[r][c] = if sample_matrix[r][c].class == Sample
                    sample_matrix[r][c].id
                  else
                    sample_matrix[r][c]
                  end
      end
    end

    self.matrix = m

  end

  # @see #associate
  def set_matrix(m)
    # TODO make this an alias of matrix=()
    associate m
  end

  def get_matrix
    datum[:matrix]
  end

  # Get matrix of {Sample} ids.
  #
  # @return [Array<Array<Integer>>]
  def matrix
    datum[:matrix]
  end

  # Set the matrix associated with the collection to the matrix of Sample ids m, whatever matrix was associated with the collection is lost.
  def matrix=(m)
    d = datum
    self.datum = d.merge(matrix: m)
  end

  # With no options, returns the indices of the next element of the collections, skipping to the next column or row if necessary.
  # With the option skip_non_empty: true, returns the next non empty indices. Returns nil if [r,c] is the last element of the collection.
  #
  # @param r [Integer] row
  # @param c [Integer] column
  # @param options [Hash]
  # @option options [Bool] :skip_non_empty  next non-empty indices
  def next(r, c, options = {})

    opts = { skip_non_empty: false }.merge options

    m = matrix
    nr, nc = dimensions

    (r..nr - 1).each do |row|
      (0..nc - 1).each do |col|
        next unless row > r || col > c
        return [row, col] if !opts[:skip_non_empty] || m[row][col] == EMPTY
      end
    end

    [nil, nil]

  end

  # Returns the dimensions of the matrix associated with the collection.
  #
  # @return [Array<Fixnum>]
  def dimensions
    m = matrix
    if m && m[0]
      [m.length, m[0].length]
    else
      [0, 0]
    end
  end

  # Returns a string describing the indices of the non empty elements in the collection. For example,
  # the method might return the string "1,1 - 5,9" to indicate that collection contains samples in
  # those indices. Note that the string is adjusted for viewing by the user, so starts with 1 instead of 0 for rows and columns.
  #
  # @return [String]
  def non_empty_string

    m = matrix
    max = [0, 0]

    (0..m.length - 1).each do |r|
      (0..m[r].length - 1).each do |c|
        max = [r, c] if m[r][c] != EMPTY
      end
    end

    if m.length > 1
      "1,1 - #{max[0] + 1}, #{max[1] + 1}"
    else
      "1 - #{max[1] + 1}"
    end

  end

end
