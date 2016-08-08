class PlansController < ApplicationController

  def show
    respond_to do |format|
      format.html { render layout: 'browser' }
    end    
  end

  def manager
    respond_to do |format|
      format.html { render layout: 'browser' }
    end    [[]]
  end

  def sid str
    str.split(':')[0]
  end

  def value data
 
    if data.class == Array
      data.collect { |str| Sample.find(sid(str)) }
    else
      Sample.find(sid(data))
    end

  end

  def show
    render json: Plan.find(params[:id]).serialize
  end

  def plan

    ot = OperationType.find(params[:ot_id])

    operations = params[:operations].collect do |o|
      op = ot.operations.create status: "planning", user_id: current_user.id
      ot.inputs.each do |input|
        op.set_input input.name, value(o[:fvs][input.name])
      end
      ot.outputs.each do |output|
        op.set_output output.name, value(o[:fvs][output.name])
      end      
      op
    end

    planner = Planner.new OperationType.all
    planner.plan_trees operations   

    render json: Planer.plan.serialize

    # render json: {
    #   trees: operations.collect { |op| op.serialize },
    #   plan: Plan.find(planner.plan.id).as_json(include: { operations: { methods: :field_values } } ),
    #   issues: operations.collect { |op| op.issues }.flatten
    # }

  end

  def index

    respond_to do |format|
      format.json { render json: Plan.where(user_id: current_user.id).as_json(methods: :goals) }
      format.html { render layout: 'browser' }
    end  

  end

end