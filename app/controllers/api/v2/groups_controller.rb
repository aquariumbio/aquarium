class Api::V2::GroupsController < ApplicationController

  def index
    # TODO: ADD PERMISSIONS

    res = Group.find_by_sql "select * from groups"

    render json: res and return
  end

  def group
puts '>>> group#group'
    # TODO: ADD PERMISSIONS

    # GET GROUP
    id = params[:id].to_i
    group = Group.find(id) rescue nil
    render json: { "error" => "invalid group" } and return if !group

    render json: group
  end

  def users
    # TODO: ADD PERMISSIONS

    # GET GROUP
    id = params[:id].to_i
    group = Group.find(id) rescue nil
    render json: { "error" => "invalid group" } and return if !group

    # TODO: THIS IS A BAND-AID UNTIL WE MOVE TO V2
    sql="
      select u.id, u.name, u.login
      from groups g
      inner join memberships m on m.group_id = g.id
      inner join users u on u.id = m.user_id
      where g.id = #{id}
      order by u.name, u.login
    "
    res = User.find_by_sql sql

    # HACK TO PREVENT AS_JSON OVERRIDE (DEF AS_JSON IN USER.RB)
    # TODO: REMOVE ONCE DEF AS_JSON IS FIXED
    result = []
    res.each do |r|
      result << { :id => r.id, :name => r.name, :login => r.login }
    end

    render json: result
  end
end
