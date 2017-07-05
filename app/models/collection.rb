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

  def position s
    pos = self.get_where self.to_sample_id(s)
    pos.first
  end

  def self.parts s, ot=nil
    plist = []
    Collection.containing(s,ot).reject { |c| c.deleted? }.each do |c|
      plist << Collection.find(c.id).position(s).merge(collection: c)
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

  def apportion r, c
    self.matrix = (Array.new(r,Array.new(c,EMPTY)))
  end

  # Finds rows, cols in which block is true
  def matrix_where
    raise "need selection block" unless block_given?
    self.matrix.map.with_index do |row, r|
      cols_where = row.each_index.select { |i| Proc.new.call(row[i]) }
      cols_where.map { |c| [r, c] }
    end.select { |d| d.any? }.flatten(1)
  end

  # Finds rows, cols that equal val
  def get_where val
    self.matrix_where { |x| x == self.to_sample_id(val) }
  end

  # Gets all empty rows, cols
  def get_empty
    self.matrix_where { |x| x == EMPTY }
  end

  # Gets all non-empty rows, cols
  def get_non_empty
    self.matrix_where { |x| x != EMPTY }
  end

  def num_samples
    get_non_empty.size
  end

  # Changes Item, String, or Sample to a sample.id for storing into a collection matrix
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
  # ==== Examples
  #
  # c = Collection.find_by_id(1)
  # c.matrix # [[-1, -1, 3], [4, -1, -1]]
  # c.add_one(777)
  # c.matrix
  #   [ [777, -1, 3],
  #     [4, -1, -1] ]
  # c.add_one(888)
  #   [ [777, 888, 3],
  #     [4, -1, -1] ]
  # c.add_one(999, reverse: true)
  #   [ [777, 888, 3],
  #     [4, -1, 999] ]
  def add_one x, options={}
    opts = { reverse: false }.merge(options)
    r, c = [nil, nil]
    if opts[:reverse]
      r, c = self.get_empty.last
    else
      r, c = self.get_empty.first
    end
    self.set r, c, x
    [r, c, x]
  end

  def remove_one x=nil, options={}
    self.subtract_one(x, options)
  end

  def subtract_one x=nil, options={}
    opts = { reverse: true }.merge(options)
    r, c = [nil, nil]
    sel = self.get_non_empty
    sel = self.get_where x if not x.nil?
    if opts[:reverse]
      r,c = sel.last
    else
      r,c = sel.first
    end
    self.set r, c, EMPTY
    [r, c, x]
  end

  def capacity
    d = self.dimensions
    d[0] * d[1]
  end

  def full?
    self.get_empty.empty?
  end

  def set r, c, x
    if self.full?
      raise "Cannot set, collection is full (#{self.num_samples} samples)"
    end
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

  def set_matrix m
    self.associate m
  end

  def get_matrix
    self.datum[:matrix]
  end

  def matrix
    self.datum[:matrix]
  end

  def matrix= m
    d = self.datum
    self.datum = d.merge( { matrix: m } )
  end

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

  #def [](i)
  #  self.matrix[i]
  #end

  def dimensions
    m = self.matrix
    if m && m[0]
      [ m.length, m[0].length ]
    else
      [ 0, 0 ]
    end
  end

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
