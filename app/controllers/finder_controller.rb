class FinderController < ApplicationController

  before_filter :signed_in_user

  def projects
    render json: (Sample.all.collect { |s| s.project }).uniq.sort
  end

  def types
    spec = JSON.parse( params[:spec], symbolize_names: true )
    render json: (Sample.includes('sample_type').where("project = ?", spec[:project]).collect{|s| s.sample_type.name }).uniq.sort
  end

  def samples
    spec = JSON.parse( params[:spec], symbolize_names: true )
    s = Sample.joins(:sample_type).where(project: spec[:project], sample_types: { name: spec[:type] } )
    render json: (s.collect{|s| s.name }).uniq.sort
  end

  def containers
    spec = JSON.parse( params[:spec], symbolize_names: true )
    render json: (ObjectType.joins(:items => :sample).where(:samples => { name: spec[:sample] }).collect { |o| o.name }).uniq.sort
  end

  def items
    spec = JSON.parse( params[:spec], symbolize_names: true )
    render json: (Item.joins(:sample,:object_type).where(:samples => { name: spec[:sample] }, :object_types => { name: spec[:container] }).collect { |i| i.id }).sort
  end

end
