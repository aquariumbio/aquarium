# frozen_string_literal: true

# locators table
class Locator < ActiveRecord::Base

  def self.create_from(item)
    # get wizard id
    sql = "
      select w.* from
      object_types ot
      inner join wizards w on w.name = ot.prefix
      where ot.id = #{item.object_type_id}
      limit 1
    "
    wizard = (Wizard.find_by_sql sql)[0] rescue nil
    return nil, nil if !wizard

    # find locator to edit if there is one
    sql = "
      select * from locators
      where wizard_id = #{wizard.id} and item_id is null
      order by number
      limit 1
    "
    locator = (Locator.find_by_sql sql)[0]

    if !locator
      sql = "select count(*) from locators where wizard_id = #{wizard.id}"
      number = Locator.count_by_sql sql

      locator = Locator.new({
        wizard_id: wizard.id,
        number: number
      })
    end

    locator.item_id = item.id
    locator.save

    # calculate location from number
    spec =JSON.parse(wizard.specification)
    items_per_box = spec['fields']['2']['capacity'].to_i
    boxes_per_section = spec['fields']['1']['capacity'].to_i

    if items_per_box <= 0
      # infinite items per box
      section_number = 0
      box_number = 0
      item_number = locator.number
    elsif boxes_per_section <= 0
      # infinite boxes per section
      section_number = 0
      box_number = locator.number / items_per_box
      item_number = locator.number - box_number * items_per_box
    else
      section_number = locator.number / (boxes_per_section * items_per_box) # section number
      leftover_items = locator.number - section_number * boxes_per_section * items_per_box # leftover items
      box_number = leftover_items / items_per_box # box number
      item_number = leftover_items - box_number * items_per_box # item number
    end

   location = "#{wizard.name}.#{section_number}.#{box_number}.#{item_number}"

    return locator, location
  end

  def self.remove(item_id)
    sql = "update locators set item_id = NULL where item_id = #{item_id}"
    Locator.connection.execute (sql)
  end
end
