class WorkflowThread < ActiveRecord::Base

  attr_accessible :workflow_id, :process_id, :specification, :user_id

  has_many :workflow_associations, foreign_key: :thread_id
  belongs_to :workflow
  belongs_to :workflow_process, foreign_key: :process_id
  belongs_to :user

  def associations
    workflow_associations
  end

  def sample_ids
    (associations.select { |a| a.sample_id }).collect { |a| a.sample_id }
  end

  def spec
    JSON.parse specification, symbolize_names: true
  end

  def valid_sample_name str
    str.class == String && str.split(':').length == 2
  end

  def validate

    s = spec
    form = Workflow.find(workflow_id).form

    (form[:inputs]+form[:outputs]).reject { |p| p[:hidden] }.each do |input|
      component = s.find { |c| c[:name] == input[:name] }
      if input[:is_vector]
        raise "#{input[:description]} (#{input[:name]}) is not specified." unless component && component[:sample].class == Array
        (0..component[:sample].length-1).each do |i|
          raise "#{input[:description]} (#{input[:name]}[#{i}]) is not specified." unless valid_sample_name(component[:sample][i])
        end
      else
        raise "#{input[:description]} (#{input[:name]}) is not specified." unless component && valid_sample_name(component[:sample])
      end
    end

    form[:parameters].each do |input|
      component = s.find { |c| c[:name] == input[:name] }
      # TODO: Typecheck component
      raise "The parameter '#{input[:name]}' is not defined." unless component 
    end

    return true

  end

  def self.create spec, wid, user

    t = WorkflowThread.new workflow_id: wid.to_i, specification: spec.to_json , user_id: user.id   
    t.validate
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
        (0..ispec[:sample].length-1).collect do |i|
          if ispec[:sample][i].as_sample_id != except.to_i
            samples << {
              name: "#{ispec[:name]}[#{i}]",
              sample: Sample.find(ispec[:sample][i].as_sample_id).for_folder(self.id)
            }
          end
        end
      else
        if ispec[:sample].as_sample_id != except.to_i
          s = Sample.find_by_id(ispec[:sample].as_sample_id)
          samples << {
            name: ispec[:name],
            sample: s ? s.for_folder(self.id) : {}
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

  def self.okay_to_drop? workflow_thread,user

    warn "Could not find a thread with the specified ID" and return false unless workflow_thread
    workflow_associations=workflow_thread.associations
    wokflow_association=workflow_associations.detect { |wokflow_association| !wokflow_association.process_id}
    warn "The thread requested for deletion is already associated with a process" and return false unless wokflow_association
    true
  end

end
