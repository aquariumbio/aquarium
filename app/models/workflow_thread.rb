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
          wa = WorkflowAssociation.new thread_id: t.id, sample_id: ispec[:sample].as_sample_id
          wa.save
        elsif ispec[:sample].class == Array
          ispec[:sample].each do |s|
            wa = WorkflowAssociation.new thread_id: t.id, sample_id: s.as_sample_id
            wa.save
          end
        end
      elsif ispec[:item]
        wa = WorkflowAssociation.new thread_id: t.id, item_id: ispec[:item]
        wa.save
      end
    end

    t

  end

  def parts except

    samples = []

    (spec.select { |p| p[:sample] }).collect do |ispec|
      if ispec[:sample].class == Array
        (0...ispec[:sample].length-1).collect do |i|
          if ispec[:sample][i].as_sample_id != except.to_i
            samples << {
              name: "#{ispec[:name]}[#{i}]",
              sample: Sample.find(ispec[:sample][i].as_sample_id).for_folder
            }
          end
        end
      else
        if ispec[:sample].as_sample_id != except.to_i
          samples << {
            name: ispec[:name],
            sample: Sample.find(ispec[:sample].as_sample_id).for_folder
          }
        end
      end
    end

    params = (spec.select { |p| !p[:type] && p[:value] }).collect do |ispec|
      {
        name: ispec[:name],
        value: ispec[:value]
      }
    end 

    data = (spec.select { |p| p[:type] }).collect do |ispec|
      {
        name: ispec[:name],
        value: ispec[:value]
      }
    end 

    { samples: samples, params: params, data: data }

  end

end
