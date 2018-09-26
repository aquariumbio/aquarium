

# A subclass of {Item} that has associated parts via the {PartAssociation} model. Stripwells, 
# 96 well plates, and gels are examples. Note that you may in some cases be working with an item
# that is also a {Collection}, which you can tell by checking that item.collection? In this case you
# promote the item using the ruby method becomes. 
# @example Cast an item as a collection
#   collection = item.becomes Collection
# @api krill
class Collection < Item

  has_many :part_associations, foreign_key: :collection_id

  def part_association_list
    # this works but rails generated part_associations seems not to
    PartAssociation.where collection_id: id
  end

  # Remove all part data associations with the matching key
  # @param key [String]
  # @return [Collection] the collection, for chaining
  def drop_data_matrix(key)
    ids = data_matrix(key).flatten.compact.collect { |da| da.id }
    DataAssociation.where(id: ids).destroy_all
    self
  end

  # Create or assign data to parts according to the given key and matrix.
  # @param key [String]
  # @param matrix [Array] an array of arrays of either numbers or strings whose dimensions are either equal to or small than the collection's dimensions
  # @option [Array] :offset the offset used to compute which sub-matrix of parts to which the data should be assigned
  # @return [Array] the part matrix, with new data associations inserted if required
  def set_data_matrix(key, matrix, offset: [0,0])

    pm = part_matrix
    dm = data_matrix(key)
    r,c = dimensions
    parts = []
    pas = []
    das = []

    # REDO
    # 1. make new pas
    # 2. make new parts and bulk save to get ids
    # 3. associate parts with pas
    # 4. bulk save pas
    # 5. make new das
    # 6. bulk save pas

    collection_id_string = SecureRandom.hex # random string used to identify saved parts  

    each_row_col(matrix,offset: offset) do |x,y,ox,oy|
      if pm[ox][oy]
        if dm[ox][oy]
          dm[ox][oy].object = {key => matrix[x][y]}.to_json
          das << dm[ox][oy]
        else
          das << pm[ox][oy].lazy_associate(key, matrix[x][y])
        end
      else
        parts << Item.new(quantity: 1, inuse: 0, object_type_id: part_type.id, data: collection_id_string)
      end
    end

    Item.import parts unless parts.empty?
    parts = Item.where(data: collection_id_string) # get the parts just made so we have the ids
    parts.each do |p|                              # erase temporary id
      p.data = nil
      p.save
    end
    index = 0

    each_row_col(matrix, offset: offset) do |x,y,ox,oy|
      if !pm[ox][oy]
        pas << PartAssociation.new(collection_id: id, part_id: parts[index].id, row: ox, column: oy)
        das << parts[index].lazy_associate(key, matrix[x][y])
        index += 1
      end
    end

    PartAssociation.import pas unless pas.empty?
    DataAssociation.import das unless das.empty?  

    pm

  end

  # Create or assign zeros to all part data associations for the given key
  # @param key [String]
  # @return [Array] the part matrix, with new data associations inserted if required  
  def new_data_matrix(key)
    r,c = dimensions
    set_data_matrix key, Array.new(r){Array.new(c,0.0)}
  end

  # @private
  def print_data_matrix(key)
    dm = data_matrix key
    dm.each do |row|
      vals = row.collect { |e| e ? e.value : '-' }
      puts "#{vals.join(', ')}"
    end
  end

  # Create or assign data for the given key at the specific row and column
  # @param key [String]
  # @param r [Fixnum] the row
  # @param c [Fixnum] the column
  # @param value [Float|Fixnum|String]
  # @return [Array] the part matrix, with new data associations inserted if required  
  # @return [Collection] the collection, for chaining
  def set_part_data(key, r, c, value)

    pm = part_association r, c
    if pm
      pm.part.associate key, value
    else
      pa = initialize_part r, c
      pa.part.associate key, value
    end

    self

  end

  # Retrieve data at the specified row and column for the given key
  # @param key [String]
  # @param r [Fixnum] the row
  # param c [Fixnum] the column
  # @return [Array] the part matrix, with new data associations inserted if required  
  # @return [String|Float] The resulting data
  def get_part_data(key, r, c)

    pa = part_association r, c
    if pa && pa.part
      pa.part.get key
    else
      nil
    end

  end

  # Iterate over all rows and columns of the given matrix, adding the offset
  # @example Iterate over a sub-matrix
  #   collection.each_row_column([[1,2],[3,4]], offset: [1,1]) do |r,c,x,y|
  #     # r, c will be the row and column of the matrix argument
  #     # x, y will be the row and column of the collection's part matrix
  #   }
  def each_row_col(matrix, offset: [0,0])
    dr, dc = dimensions
    (0...matrix.length).each do |r|
      (0...matrix[r].length).each do |c|  
        x = r + offset[0]
        y = c + offset[1]
        if x < dr && y < dc     
          yield r, c, x, y
        end
      end
    end

  end

  # @private
  def initialize_part(r, c, sample: nil)
    
    pa = part_association r, c

    if pa
      if !pa.part_id
        part = Item.make({ quantity: 1, inuse: 0 }, sample: sample, object_type: part_type) 
        pa.part_id = part.id
        pa.save
      end
    else
      part = Item.make({ quantity: 1, inuse: 0 }, sample: sample, object_type: part_type)      
      pa = PartAssociation.new( collection_id: id, part_id: part.id,  row: r, column: c ) 
      pa.save
    end

    pa

  end

  # @private
  def part_association(r, c)
    pas = PartAssociation.where(collection_id: id, row: r, column: c)
    if pas.length == 1
      pas[0]
    else
      nil
    end
  end

  # Return the matrix of data associations associated with the given key
  # @param key [String]
  # @return [Array] an array of array of {DataAssociation}s
  def data_matrix(key)

    pas = part_association_list
    part_ids = pas.collect { |p| p.part_id }.uniq

    das = DataAssociation.where(parent_class: "Item", parent_id: part_ids, key: key)

    r,c = self.dimensions
    m = Array.new(r){Array.new(c)}

    pas.each do |pa|
      m[pa.row][pa.column] = das.find { |da| da.parent_id == pa.part_id }
    end

    m

  end

  # Return the matrix of data association values associated with the given key
  # @param key [String]
  # @return [Array] an array of array of {DataAssociation} values
  def data_matrix_values key
    (data_matrix(key).map { |row| row.map { |da| da ? da.value : nil } })
  end

  # Retrive the part at position r, c
  # @param r [Fixnum] the row
  # @param c [Fixnum] the column
  # @return [Item] 
  def part(r, c)
    pas = PartAssociation.includes(:part).where(collection_id: id, row: r, column: c)
    if pas.length == 1
      pas[0].part
    else
      nil
    end
  end

  # Retrive a matrix of all parts. If no part is present for a given row and column, that entry will be nil
  # @return [Array] an array of arrays of {Item}s -- dimensions match collection's dimensions
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

  # @private
  def part_matrix_as_json
    part_matrix.as_json(include: [ { sample: { include: :sample_type } }, :object_type ] )
  end

  # Assign samples to the parts at positions specified by pairs
  # @param sample [Sample]
  # @param pairs [Array] of the form [ [r1,c1], [r2, c2] ... ]
  # @return [Collection] can be chained
  def assign_sample_to_pairs(sample, pairs) 

    pm = part_matrix

    pairs.each do |r,c|
      if pm[r][c] 
        old_sample_id = pm[r][c].sample_id
        pm[r][c].sample_id = sample.id
        pm[r][c].save
        associate(
          :"Sample Reassigned", 
          "The sample at #{r}, #{c} was changed from #{old_sample_id} to #{sample.id}.",
          nil,
          duplicates: true
        )
      else
        set r, c, sample
      end
    end

    self

  end

  # Unassign any existing sample associated with the parts at positions specified by pairs
  # @param pairs [Array] of the form [ [r1,c1], [r2, c2] ... ]
  # @return [Collection] can be chained
  def delete_selection(pairs)

    pairs.each do |r,c|

      pas = PartAssociation.includes(:part).where(collection_id: id, row: r, column: c)

      unless pas.empty?

        pas[0].part.mark_as_deleted
        pas[0].destroy

        associate(
          :"Part Deleted", 
          "The sample at #{r}, #{c} was deleted. " + 
          "It used to be sample #{pas[0].part.sample_id} via deleted part #{pas[0].part.id}.",
          nil,
          duplicates: true
        )

        puts "DONE!!!!!!!!!!!"

      end

    end

  end  

  EMPTY = -1 # definition of empty  

  # @private
  def self.every
    Item.joins(:object_type).where(object_types: { handler: 'collection' })
  end

  # Return a list of collections containing the given sample, and optionally of the given object
  # type.
  # @param s [Sample]
  # @option ot [ObjectType]
  # @return [ActiveRecord::Relation]
  def self.containing(s, ot = nil)
    return [] unless s
    cids = PartAssociation.joins(:part).where("sample_id = ?", to_sample_id(s)).map(&:collection_id)
    Collection.where(id: cids).select { |c| !ot || c.object_type_id == ot.id }
  end

  # @private
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

  
  # Get a list of the of the form \[ {row: r, column: c, collection: col}, ... \] containing
  # the specificed sample.
  # @param s [Sample]
  # @option ot [ObjectType]
  # @return [Array]  
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
  def self.new_collection(ctype)

    if ctype.class == String
      name = ctype
      o = ObjectType.find_by_name(name)
    else
      o = ctype
    end
    
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

  # Sets the matrix for the collection to an empty rxc matrix and saves the collection to the database,
  # whatever matrix was associated with the collection is lost.
  #
  # @param r [Integer] row
  # @param c [Integer] column
  def apportion(r, c)
    ### self.matrix = Array.new(r, Array.new(c, EMPTY))
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
    PartAssociation
      .joins(:part)
      .where("sample_id = ? AND collection_id = ?", to_sample_id(val), id)
      .collect { |pa| [pa.row, pa.column] }
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

  # Fill collecion with samples.
  #
  # @param [Array<Sample>]  samples to put in collection
  # @return [Array<Sample>]  samples that were not filled
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
  def to_sample_id_matrix(sample_matrix)

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
  # a matrix of sample ids. Only sample ids are saved to the matrix. Whatever matrix was associated with the collection is lost.
  #
  # @param sample_matrix [Array<Array<Sample>>, Array<Array<Fixnum>>]

  def associate_matrix(sample_matrix)

    dr = sample_matrix.length
    dc = sample_matrix[0].length
    sample_matrix_aux = to_sample_id_matrix sample_matrix  
    
    ActiveRecord::Base.transaction do

      clear
      @matrix_cache = nil

      # create parts
      parts = []
      collection_id_string = SecureRandom.hex # random string used to identify saved parts
      (0...dr).each do |r|
        (0...dc).each do |c|
          if sample_matrix_aux[r][c] != nil
            parts << Item.new(quantity: 1, inuse: 0, sample_id: sample_matrix_aux[r][c], object_type_id: part_type.id, data: collection_id_string)
          end
        end
      end
      Item.import parts
      parts = Item.where(data: collection_id_string) # get the parts just made so we have the ids
      parts.each do |p|                              # erase temporary id
        p.data = nil
        p.save
      end      
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
    part_association_list.map(&:destroy)
  end

  # @see #associate
  def set_matrix(m)
    associate_matrix m
  end

  def get_matrix
    matrix
  end

  # Get matrix of {Sample} ids.
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

  # Set the matrix associated with the collection to the matrix of Sample ids m, whatever matrix was associated with the collection is lost.
  def matrix=(m)
    associate_matrix m
  end

  # With no options, returns the indices of the next element of the collection, skipping to the next column or row if necessary.
  # With the option skip_non_empty: true, returns the next non empty indices. Returns nil if [r,c] is the last element of the collection
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
    # Should look up object type dims instead
    dims = [object_type.rows,object_type.columns]
    dims[0] = 12 unless dims[0] != nil
    dims[1] = 1 unless dims[1] != nil
    dims
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

  # @private
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
