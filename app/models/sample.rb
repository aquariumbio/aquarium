# frozen_string_literal: true

# A named, biologically unique definition for an instance of a {SampleType}, such as a specific Primer, Fragment, Plasmid, or Yeast Strain
# A Sample has many {Item}s in inventory
# @api krill

class Sample < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  include SampleValidator

  include FieldValuer
  def parent_type # interface with FieldValuer
    sample_type
  end

  after_destroy :destroy_fields

  attr_accessible :user_id, :project, :user_id, :description

  # Gets the name of Sample.
  #
  # @return [String]  the name of the Sample. For example, a sample whose SampleType is "Plasmid" might be named "pLAB1"
  attr_accessible :name

  # Gets the SampleType id of sample.
  #
  # @return [Fixnum]  id referring to the SampleType of which this sample is an instance of
  attr_accessible :sample_type_id

  belongs_to :sample_type
  belongs_to :user
  has_many :items
  has_many :post_associations

  validates_uniqueness_of :name, message: "The sample name '%{value}' is the name of an existing sample"

  validates :name, presence: true
  validates :project, presence: true
  validates :user_id, presence: true

  def self.sample_from_identifier(str)
    return unless str

    parts = str.split(': ')
    Sample.find_by_name(parts[1..-1].join(': ')) if parts.length > 1
  end

  # @example Create a new primer
  #   s = Sample.creator(
  #     {
  #       sample_type_id: SampleType.find_by_name("Primer").id,
  #       description: "This is a test",
  #       name: "Yet Another Primer Test",
  #       project: "Auxin",
  #       field_values: [
  #         { name: "Anneal Sequence", value: "ATTCTA" },
  #         { name: "Overhang Sequence", value: "ATCTCGAGCT" },
  #         { name: "T Anneal", value: 70 }
  #       ]
  #     }, User.find(1))
  #
  #     s.errors.any?
  def self.creator(raw, user)

    sample = Sample.new
    sample.user_id = user.id
    sample.sample_type_id = raw[:sample_type_id]
    sample.updater raw

    sample

  end

  def stringify_errors(elist)
    elist.full_messages.join(',')
  end

  def updater(raw, user = nil)
    self.name = raw[:name]
    self.description = raw[:description]
    self.project = raw[:project]

    Sample.transaction do
      save
      raise ActiveRecord::Rollback unless errors.empty?

      sample_type = SampleType.find(raw[:sample_type_id])
      if raw[:field_values]

        raw[:field_values].each do |raw_fv|

          ft = sample_type.type(raw_fv[:name])

          if ft && raw_fv[:id] && raw_fv[:deleted]

            fv = FieldValue.find_by_id(raw_fv[:id])
            fv.destroy if fv

          elsif ft && !raw_fv[:deleted] # fv might have been made and marked deleted without ever having been saved

            if raw_fv[:id]
              begin
                fv = FieldValue.find(raw_fv[:id])
              rescue Exception => e
                errors.add :missing_field_value, "Field value #{raw_fv[:id]} not found in db."
                errors.add :missing_field_value, e.to_s
                raise ActiveRecord::Rollback
              end
            else
              fv = field_values.create(name: raw_fv[:name])
            end

            if ft.ftype == 'sample'
              child = if raw_fv[:new_child_sample]
                        Sample.creator(raw_fv[:new_child_sample], user || User.find(user_id))
                      else
                        Sample.sample_from_identifier raw_fv[:child_sample_name]
                      end
              fv.child_sample_id = child.id if child
              fv.child_sample_id = nil if !child && raw_fv[:child_sample_name] == ''
              if !child && ft.required && raw_fv[:child_sample_name] != ''
                errors.add :required, "Sample required for field '#{ft.name}' not found or not specified."
                raise ActiveRecord::Rollback
              end
              unless !child || child.errors.empty?
                errors.add :child_error, "#{ft.name}: " + stringify_errors(child.errors)
                raise ActiveRecord::Rollback
              end
            elsif ft.ftype == 'number'
              fv.value = raw_fv[:value].to_f
            else # string, url
              fv.value = raw_fv[:value]
            end

            puts 'before fv saved: {fv.inspect}'
            fv.save
            puts "fv saved. now #{fv.inspect}"

            unless fv.errors.empty?
              errors.add :field_value, "Could not save field #{raw_fv[:name]}: #{stringify_errors(fv.errors)}"
              raise ActiveRecord::Rollback
            end

          end # if

        end # each

      end # if

    end
  end

  # Return all items of this {Sample} in the provided {ObjectType}.
  # @param container [String] {ObjectType} name
  # @example find a 1 kb ladder for gel electrophoresis
  #   ladder_1k = Sample.find_by_name("1 kb Ladder").in("Ladder Aliquot")
  # @return [Array<Item>]
  def in(container)

    c = ObjectType.find_by_name container
    if c
      Item.where("sample_id = ? AND object_type_id = ? AND NOT ( location = 'deleted' )", id, c.id)
    else
      []
    end

  end

  def to_s
    "<a href='/samples/#{id}' class='aquarium-item' id='#{id}'>#{id}</a>"
  end

  # Get {User} who owns this {Sample}.
  #
  # @return [User]
  def owner
    u = User.find_by_id(user_id)
    if u
      u.login
    else
      '?'
    end
  end

  # Make a new Item out of this sample, with some object type.
  #
  # @param object_type_name [String]  describes the object type
  #               that will be used to make a new Item
  # @return [Item]  an item associated with this sample and in
  #               the container described by `object_type_name`
  #               The location of the item is determined
  #               by the location wizard
  def make_item(object_type_name)

    ot = ObjectType.find_by_name(object_type_name)
    raise "Could not find object type #{name}" unless ot

    Item.make({ quantity: 1, inuse: 0 }, sample: self, object_type: ot)

  end

  def num_posts
    post_associations.count
  end

  def self.okay_to_drop?(sample, user)

    warn('Could not find sample')                                                && (return false) unless sample
    warn("Not allowed to delete sample #{sample.id}")                            && (return false) unless sample.user_id == user.id
    warn("Could not delete sample #{sample.id} because it has associated items") && (return false) unless sample.items.empty?

    true

  end

  def data_hash
    JSON.parse(data, symbolize_names: true)
  end

  def full_json

    sample_hash = as_json(
      include: { sample_type: { include: :object_types, methods: :field_types } },
      methods: :full_field_values
    )

    # rename field for compatibility with ng-control/sample.js
    sample_hash['field_values'] = sample_hash.delete 'full_field_values'

    sample_hash

  end

end
