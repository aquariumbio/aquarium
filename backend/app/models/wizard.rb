# wizards table
class Wizard < ActiveRecord::Base

  validates :name,        presence: true
  validates :description, presence: true

  # Return all wizards.
  #
  # @return all wizards
  def self.find_all
    Wizard.order(:name)
  end

  # Return all wizards beginning with first letter l ('*' as non-alphanumeric wildcard).
  #
  # @return all wizards beginning with first letter l ('*' as non-alphanumeric wildcard)
  def self.find_by_first_letter(l)
    if l == "*"
      sql = "select * from wizards where (name regexp '^[^a-zA-Z].*') order by name"
    else
      sql = "select * from wizards where name like '#{l}%' order by name"
    end
    Wizard.find_by_sql sql
  end

  # Return a specific wizard.
  #
  # @param id [Int] the id of the wizard
  # @return the wizards
  def self.find_id(id)
    Wizard.find_by(id: id)
  end

  # Return the containers for the wizard.
  #
  # @return containers
  def containers
    # get containers
    wheres = ActiveRecord::Base.sanitize_sql(['prefix = ?', name])
    sql = "
      select id, name from object_types where #{wheres} order by name
    "
    containers = ObjectType.find_by_sql sql
  end

  # Return the boxes for the wizard.
  #
  # @return boxes
  def boxes
    # get box count
    sql = "select max(number) as 'max' from locators where wizard_id = #{id} and item_id is not null"
    items = (Locator.find_by_sql sql)[0].max.to_i

    # get items per box, assume infinite if <= 0
    # get boxes per section, assume infinite if <= 0
    spec = JSON.parse(self.specification)
    items_per_box = spec['fields']['2']['capacity'].to_i
    boxes_per_section = spec['fields']['1']['capacity'].to_i

    if items ==  0
      number_of_boxes = 1
      number_of_sections = 1
    else
      number_of_boxes = items_per_box > 0 ? (items * 1.0 / items_per_box).ceil() : 1
      number_of_sections = boxes_per_section > 0 ? (number_of_boxes * 1.0 / boxes_per_section).ceil() : 1
    end

    boxes = []
    box = 0
    this_box = 0
    this_section = 0
    while box < number_of_boxes
      boxes << "#{name}.#{this_section}.#{this_box}"

      # next box
      box += 1

      # next section + next box
      if this_box == boxes_per_section - 1
        this_box = 0
        this_section += 1
      else
        this_box += 1
      end
    end

    # return boxes
    boxes
  end

  # Return the items for the specified box.
  #
  # @return items
  def items(box = '0.0')
    # get items per box, assume infinite if <= 0
    # get boxes per section, assume infinite if <= 0
    spec = JSON.parse(self.specification)
    items_per_box = spec['fields']['2']['capacity'].to_i
    boxes_per_section = spec['fields']['1']['capacity'].to_i

    # set to 0 if less than 0
    items_per_box = 0 if items_per_box < 0
    boxes_per_section = 0 if boxes_per_section < 0

    # get section + box
    section_box = box.split('.')
    section = section_box[-2].to_i
    box = section_box[-1].to_i

    # set to 0 if less than 0
    section = 0 if section < 0
    box = 0 if box < 0

    if items_per_box == 0
      sql = "select number, item_id from locators where wizard_id = #{id} and item_id is not null order by number"
      item_data = Locator.find_by_sql sql

      # calculate first item
      first_item = 0
      last_item = item_data[-1] ? item_data[-1].number : 0

      # initialize items array
      items = []
      n = 0
      while n < last_item + 1 do
        items << { number: n, item_id: nil}
        n += 1
      end
    else
      # calculate first item
      first_item = section * items_per_box * boxes_per_section + box * items_per_box
      last_item = first_item + items_per_box -1

      sql = "
        select mod(number, #{items_per_box}) as 'number', item_id
        from locators
        where wizard_id = #{id}
        and item_id is not null
        and number >= #{first_item}
        and number < #{first_item + items_per_box}
      "
      item_data = Locator.find_by_sql sql

      # initialize items array
      items = []
      n = 0
      while n < items_per_box do
        items << { number: n, item_id: nil}
        n += 1
      end
    end

    # insert data
    item_data.each do |i|
      items[i.number][:item_id] = i.item_id
    end

    return items, "#{name}.#{section}.#{box}"
  end

  # Create a wizard
  #
  # @param wizard [Hash] the wizard
  # @option wizard[:name] [String] the name
  # @option wizard[:description] [String] the description
  # @option wizard[:specification] [String] the specification
  # return the wizard
  def self.create_from(wizard)
    # Read the parameters
    name = Input.text(wizard[:name])
    description = Input.text(wizard[:description])
    specification = wizard[:specification].to_json

    wizard_new = Wizard.new(
      name: name,
      description: description,
      specification: specification
    )

    valid = wizard_new.valid?
    return false, wizard_new.errors if !valid

    # Save the wizard if it is valid
    wizard_new.save

    return wizard_new, false
  end

  # Update a wizard
  #
  # @param wizard [Hash] the wizard
  # @option wizard[:name] [String] the name
  # @option wizard[:description] [String] the description
  # @option wizard[:specification] [String] the specification
  # return the wizard
  def update(wizard)
    # Read the parameters
    input_name = Input.text(wizard[:name])
    input_description = Input.text(wizard[:description])
    input_specification = wizard[:specification].to_json

    self.name = input_name
    self.description = input_description
    self.specification = input_specification

    valid = self.valid?
    return false, self.errors if !valid

    # Save the wizard if it is valid
    self.save

    return self, false
  end
end
