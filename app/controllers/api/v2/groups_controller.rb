# typed: false
# frozen_string_literal: true

class Api::V2::GroupsController < ApplicationController
  include ApiHelper

  def index
    # TODO: ADD PERMISSIONS

    res = Group.find_by_sql 'select * from groups'

    render json: api_ok(res) and return
  end

  def group
    # TODO: ADD PERMISSIONS

    # GET GROUP
    if params[:id] == 'technicians'
      # SPECIAL CASE FOR TECHNICIANS
      group = Group.technicians
    else
      id = params[:id].to_i
      group = Group.find_by(id: id)
    end
    render json: api_error({ 'group_id' => ['invalid group'] }) and return unless group

    render json: api_ok(group)
  end

  def users
    # TODO: ADD PERMISSIONS

    # GET GROUP
    if params[:id] == 'technicians'
      # SPECIAL CASE FOR TECHNICIANS
      group = Group.technicians
      id = group.id
    else
      id = params[:id].to_i
      group = Group.find_by(id: id)
    end
    render json: api_error({ 'group_id' => ['invalid group'] }) and return unless group

    job_count = false
    params[:options].to_a.each do |s|
      job_count = true if s == 'job_count'
    end

    # TODO: MOVE SQL TO MODEL
    # TODO: THIS IS A BAND-AID UNTIL WE MOVE TO VE
    if job_count
      sql = "
        select u.id, u.name, u.login, jc.n
        from groups g
        inner join memberships m on m.group_id = g.id
        inner join users u on u.id = m.user_id
        left join (
          select assigned_to, count(*) as 'n'
          from view_job_assignments
          where pc != -2
          group by assigned_to
        ) jc on jc.assigned_to = u.id
        where g.id = #{id}
        order by u.name, u.login
      "
      res = User.find_by_sql sql

      # HACK: TO PREVENT AS_JSON OVERRIDE (DEF AS_JSON IN USER.RB)
      # TODO: REMOVE ONCE DEF AS_JSON IS FIXED
      result = []
      res.each do |r|
        result << { id: r.id, name: r.name, login: r.login, job_count: r.n }
      end
    else
      sql = "
        select u.id, u.name, u.login
        from groups g
        inner join memberships m on m.group_id = g.id
        inner join users u on u.id = m.user_id
        where g.id = #{id}
        order by u.name, u.login
      "
      res = User.find_by_sql sql

      # HACK: TO PREVENT AS_JSON OVERRIDE (DEF AS_JSON IN USER.RB)
      # TODO: REMOVE ONCE DEF AS_JSON IS FIXED
      result = []
      res.each do |r|
        result << { id: r.id, name: r.name, login: r.login }
      end
    end

    render json: api_ok(result)
  end
end
