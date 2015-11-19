class Workflow < ActiveRecord::Base

  include WorkflowAux

  has_many :workflow_processes

  attr_accessible :name, :specification

  def processes
    self.workflow_processes
  end

  def parse_spec
    JSON.parse specification, symbolize_names: true
  end

  def export
    complete_spec.merge({form: form,github_edit_path: github})
  end

  def github
    "#{Bioturk::Application.config.workflow[:github]}#{Bioturk::Application.config.workflow[:repo]}/edit/master/auto/#{Rails.env}"
  end

  def complete_spec
    unless @fullspec
      s = parse_spec     
      s[:operations] = s[:operations].collect { |o|
        o.merge operation: Operation.find(o[:id]).export 
      }
      @fullspec = { id: id, name: name, specification: s }
    end
    @fullspec
  end

  def add_operation op
    s = parse_spec
    s[:operations].push(op.id)
    self.specification = s.to_json
    self.save
  end

  def new_operation
    op = Operation.new
    op.save
    add_operation op
    op.export
  end

  def drop_operation op
    s = parse_spec
    s[:operations] -= [op.id]
    self.specification = s.to_json
    self.save
    op.destroy if op.okay_to_drop?
  end

  def identify source, dest, output, input
    s = parse_spec
    s[:io].push({from:[source,output],to:[dest,input]})
    self.specification = s.to_json
    self.save
  end

  def for_folder

    wf = self.as_json
    wf[:form] = self.form
    wf

  end

end
