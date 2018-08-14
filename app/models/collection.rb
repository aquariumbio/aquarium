

# A subclass of {Item} that has a matrix of Sample ids and does not belong to a {SampleType}
# @api krill
class Collection < Item

  has_many :part_associations, foreign_key: :collection_id

  # COLLECTION INTERFACE #####################################################################

  def part_matrix

    r,c = self.dimensions
    m = Array.new(r){Array.new(c)}

    PartAssociation
      .includes(part: [ { sample: [ :sample_type ] }, :object_type ] )
      .where(collection_id: id)
      .each do |pa| 
        m[pa.row][pa.column] = pa.part
      end

    m

  end

  def part_matrix_as_json

    j = part_matrix.as_json(include: [ { sample: { include: :sample_type } }, :object_type ] )
    puts j
    j

  end

  def assign_sample_to_pairs sample, pairs # of the form [ [r1,c1], [r2, c2] ... ]

    pm = part_matrix

    pairs.each do |r,c|
      if pm[r][c] 
        pm[r][c].sample_id = sample.id
        pm[r][c].save
      else
        set r, c, sample
      end
    end

  end

  # ORIGINAL INTERFACE #######################################################################

  EMPTY = -1 # definition of empty  

  def self.every
    Item.joins(:object_type).where(object_types: { handler: 'collection' })
  end

  def self.containing(s, ot = nil)
    return [] unless s
    cids = PartAssociation.joins(:part).where("sample_id = ?", to_sample_id(s)).map(&:collection_id)
    Collection.where(id: cids).select { |c| !ot || c.object_type_id == ot.id }
  end

  def part_type
    @part_type ||= ObjectType.find_by_name("__Part")
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

  # METHODS #########################################################################

  def self.new_collection(name)

    o = ObjectType.find_by_name(name)
    raise "Could not find object type named '#{name}'." unless o

    i = Collection.new
    i.object_type_id = o.id
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

  # Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database.
  # Whatever matrix was associated with the collection is lost
  #
  # @param r [Integer] Row
  # @param c [Integer] Column
  def apportion(r, c)
    ### self.matrix = Array.new(r, Array.new(c, EMPTY))
  end

  # Whether the matrix includes x
  #
  # @param x [Fixnum, Sample, Item]
  # @return [Boolean]
  def include?(x)
    sel = find x
    sel.any?
  end

  # Finds rows, cols in which block is true
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def select
    raise 'need selection block' unless block_given?
    matrix.map.with_index do |row, r|
      cols_where = row.each_index.select { |i| Proc.new.call(row[i]) }
      cols_where.map { |c| [r, c] }
    end.select(&:any?).flatten(1)
  end

  # Finds rows, cols that equal val
  #
  # @param val [Fixnum, Sample, Item]
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def find(val)
    PartAssociation
      .joins(:part)
      .where("sample_id = ? AND collection_id = ?", to_sample_id(val), id)
      .collect { |pa| [pa.row, pa.column] }
  end

  # Gets all empty rows, cols
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def get_empty
    select { |x| x == EMPTY }
  end

  # Gets all non-empty rows, cols
  #
  # @return [Array<Array<Fixnum>>] Array of form [[r1, c1], [r2, c2]]
  def get_non_empty
    select { |x| x != EMPTY }
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
  def self.to_sample_id(x)
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

  def to_sample_id(x)
    Collection.to_sample_id(x)
  end

  # Changes Item, String, or Sample to a sample
  #
  # class method?
  def self.to_sample(x)
    if x.class == Integer || ( x.class == Fixnum && x >= 0 ) # Not sure where "Integer" came from here ---ek
      r = Sample.find(x)
    elsif x.class == Item
      if x.sample
        r = x.sample
      else
        raise 'When the third argument to Collection.set is an item, it should be associated with a sample.'
      end
    elsif x.class == Sample
      r = x
    elsif x.class == String
      r = Sample.find(x.split(':')[0].to_i)
    elsif !x || x == -1
      r = nil
    else
      raise "Expecting item, a sample, or a sample id, but got '#{x}' which is a #{x.class}"
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
  # then finds the first [r,c] equal to x. Returns [r,c,sample_at_rc] if x is in collection. or nil if x is not found or the col.empty?
  #
  # @param x [Fixnum, Sample, Item]
  # @param options [Hash]
  # @option options [Bool] :reverse Begin from the end of the matrix
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

  # Whether the matrix has no EMPTY slots
  #
  # @return [Bool]
  def full?
    get_empty.empty?
  end

  # Whether the matrix is empty
  #
  # @return [Bool]
  delegate :empty?, to: :get_non_empty

  # Set the [r,c] entry of the matrix to id of the Sample s. If s=nil, then the [r,c] entry is cleared
  #
  # @param r [Integer] Row
  # @param c [Integer] Column
  # @param x [Fixnum, Sample, Item]
  def set(r, c, x)
    # TODO: Check dimensions
    @matrix_cache = nil
    if x == EMPTY
      pas = PartAssociation.where(collection_id: id, row: r, column: c)
      if pas.length == 1
        pas[0].destroy
      end
    else
      s = Collection.to_sample(x)
      part = Item.make({ quantity: 1, inuse: 0 }, sample: s, object_type: part_type)
      pas = PartAssociation.where(collection_id: id, row: r, column: c)
      if pas.length == 1
        pa = pas[0]
        pa.part_id = part.id
      else
        pa = PartAssociation.new( collection_id: id, part_id: part.id,  row: r, column: c )
      end
      pa.save
    end
  end

  # Fill collecion with samples
  # Return samples that were not filled
  def add_samples(samples, options = {})
    opts = { reverse: false }.merge(options)
    empties = get_empty
    empties.reverse! if opts[:reverse]
    remaining = []
    samples.zip(empties).each do |s, rc|
      if rc.nil?
        remaining << s
      else
        r, c = rc
        set r, c, s
      end
    end
    remaining
  end

  # Takes a matrix of sample ids, samples or items and returns a matrix of only sample ids
  def to_sample_id_matrix sample_matrix

    dr = sample_matrix.length
    dc = sample_matrix[0].length

    sample_matrix_aux = Array.new(dr){Array.new(dc)}

    # convert sample matrix into ids
    (0...dr).each do |r|
      (0...dc).each do |c|
        klass = sample_matrix[r][c].class
        if klass == Sample 
          sample_matrix_aux[r][c] = sample_matrix[r][c].id
        elsif klass == Item
          sample_matrix_aux[r][c] = Item.sample_id
        elsif klass == Fixnum && sample_matrix[r][c] > 0 
          sample_matrix_aux[r][c] = sample_matrix[r][c]
        else
          sample_matrix_aux[r][c] = nil
        end
      end
    end

    sample_matrix_aux

  end

  # Sets the matrix associated with the collection to the matrix m where m can be either a matrix of Samples or
  # a matrix of sample ids. Only sample ids are saved to the matrix. Whatever matrix was associated with the collection is lost
  #
  # @param sample_matrix [Array<Array<Sample>>, Array<Array<Fixnum>>]
  def associate(sample_matrix)

    dr = sample_matrix.length
    dc = sample_matrix[0].length
    sample_matrix_aux = to_sample_id_matrix sample_matrix  
    
    ActiveRecord::Base.transaction do

      clear
      @matrix_cache = nil

      # create parts
      parts = []
      collection_id_string = "__part_for_collection_#{id}__"
      (0...dr).each do |r|
        (0...dc).each do |c|
          if sample_matrix_aux[r][c] != nil
            parts << Item.new(quantity: 1, inuse: 0, sample_id: sample_matrix_aux[r][c], object_type_id: part_type.id, data: collection_id_string)
          end
        end
      end
      Item.import parts
      parts = Item.where(data: collection_id_string) # get the parts just made so we have the ids
      index = 0

      # create part associations
      pas = []
      (0...dr).each do |r|
        (0...dc).each do |c|
          if sample_matrix_aux[r][c] != nil
            pas << PartAssociation.new(collection_id: id, part_id: parts[index].id, row: r, column: c)
            index += 1
          end
        end
      end
      PartAssociation.import pas

    end

  end

  def clear
    part_associations.map(&:destroy)
  end

  # @see #associate
  def set_matrix(m)
    associate m
  end

  def get_matrix
    matrix
  end

  # Return matrix of {Sample} ids
  #
  # @return [Array<Array<Integer>>]
  def matrix
    if @matrix_cache
      @matrix_cache
    else
      r,c = self.dimensions
      m = Array.new(r){Array.new(c, EMPTY)}
      PartAssociation.includes(:part).where(collection_id: id).each do |pa|
        m[pa.row][pa.column] = pa.part.sample_id if pa.row < r && pa.column < c
      end
      @matrix_cache = m
      m
    end
  end

  # Set the matrix associated with the collection to the matrix of Sample ids m. Whatever matrix was associated with the collection is lost
  def matrix=(m)
    associate m
  end

  # With no options, returns the indices of the next element of the collection, skipping to the next column or row if necessary.
  # With the option skip_non_empty: true, returns the next non empty indices. Returns nil if [r,c] is the last element of the collection
  #
  # @param r [Integer] Row
  # @param c [Integer] Column
  # @param options [Hash]
  # @option options [Bool] :skip_non_empty Return next non-empty indices
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

  # Returns the dimensions of the matrix associated with the collection
  #
  # @return [Array<Fixnum>]
  def dimensions
    # Should look up object type dims instead
    dims = [object_type.rows,object_type.columns]
    dims[0] = 12 unless dims[0] != nil
    dims[1] = 1 unless dims[1] != nil
    dims
  end

  # Returns a string describing the indices of the non empty elements in the collection. For example,
  # the method might return the string "1,1 - 5,9" to indicate that collection contains samples in
  # those indices. Note that the string is adjusted for viewing by the user, so starts with 1 instead of 0 for rows and columns
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

  def migrate
    unless datum[:_migrated_]
      if self.data
        tempdata = JSON.parse(self.data, symbolize_names: true)
        if tempdata[:matrix]
          self.matrix = tempdata[:matrix]
          tempdata.delete :matrix
          tempdata[:_migrated_] = Date.today
          self.set_data tempdata
        end
      end
    end
  end

end
