class WorkflowThread < ActiveRecord::Base

  attr_accessible :workflow_id, :process_id, :specification

  has_many :workflow_associations, foreign_key: :thread_id
  belongs_to :workflow
  belongs_to :workflow_process, foreign_key: :process_id

  def associations
    workflow_associations
  end

  def sample_ids
    (associations.select { |a| a.sample_id }).collect { |a| a.sample_id }
  end

  def spec
    JSON.parse specification, symbolize_names: true
  end

  def self.create spec, wid

    t = WorkflowThread.new workflow_id: wid.to_i, specification: spec.to_json
    t.save 

    spec.each do |ispec| 
      if ispec[:sample]
        if ispec[:sample].class == String
          sid = ispec[:sample].as_sample_id
        else
          sid = ispec[:sample]
        end
        wa = WorkflowAssociation.new thread_id: t.id, sample_id: sid
        wa.save
      elsif ispec[:item]
        wa = WorkflowAssociation.new thread_id: t.id, item_id: ispec[:item]
        wa.save
      end
    end

    t

  end

  def parts except
    (spec.reject { |p| p[:sample] && p[:sample].as_sample_id == except}).collect do |ispec|

      if ispec[:sample]
        {
          name: ispec[:name],
          sample: Sample.find(ispec[:sample].as_sample_id).for_folder
        }
      else
        {
          name: ispec[:name],
          value: ispec[:value]
        }
      end
    end
  end

end
