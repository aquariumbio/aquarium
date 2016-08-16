class OperationTypesController < ApplicationController

  def index

    respond_to do |format|
      format.json { render json: OperationType.all.as_json(methods: [:field_types, :protocol, :cost_model, :documentation]) }
      format.html { render layout: 'browser' }
    end    
    
  end

  def add_field_types ot, fts

    if fts
      fts.each do |ft|
        if ft[:allowable_field_types]
          sample_type_names = ft[:allowable_field_types].collect { |aft| aft[:sample_type][:name] }
          container_names =  ft[:allowable_field_types].collect { |aft| aft[:object_type][:name] }          
        else
          sample_type_names = []
          container_names = []
        end
        ot.add_io ft[:name], sample_type_names, container_names, ft[:role], array: ft[:array], part: ft[:part]
      end
    end

  end

  def create

    ot = OperationType.new name: params[:name]
    ot.save
    add_field_types ot, params[:field_types]     

    ["protocol", "cost_model", "documentation"].each do |name|
      ot.new_code(name, params[name]["content"])
    end

    render json: ot.as_json(methods: [:field_types, :protocol, :cost_model, :documentation])

  end

  def code

    ot = OperationType.find(params[:id])

    c = ot.code(params[:name])
    
    if c
      logger.info "Found code: #{c.inspect}"
      c = c.commit(params[:content])
    else
      logger.info "Making new code"      
      c = ot.new_code(params[:name], params[:content])
      logger.info "  ==> New code: #{c.inspect}"      
    end

    render json: c

  end

  def update

    ot = OperationType.find(params[:id])
    ot.name = params[:name]
    ot.save

    ot.field_types.each do |ft| 
      ft.destroy
    end

    add_field_types ot, params[:field_types]

    render json: ot.as_json(methods: [:field_types, :protocol, :cost_model, :documentation])

  end

end

