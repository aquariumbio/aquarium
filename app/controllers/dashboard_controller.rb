# typed: false
# frozen_string_literal: true

class DashboardController < ApplicationController

  before_filter :signed_in_user

  def react

    render :layout => "aq2-dashboard"
  end

  def manager
    # FROM API/V2/DASHBOARD
    # TODO: MOVE SQL TO MODEL
    sql = "
      select
      j.id, j.user_id, j.state, j.created_at, j.updated_at, j.pc, j.group_id, j.submitted_by,
      vjot.operation_type_id as 'operation_type_id', vjot.name as 'operation_type_name', vjot.category as 'operation_type_category',
      vjassoc.n as 'operation_count',
      vja.assigned_by, vja.by_name, vja.by_login, vja.assigned_to, vja.to_name, vja.to_login, vja.created_at as 'assigned_at'
      from jobs j
      inner join view_job_operation_types vjot on vjot.job_id = j.id
      inner join view_job_associations vjassoc on vjassoc.job_id = j.id
      left join view_job_assignments vja on vja.job_id = j.id
      where j.pc in (-1,0)
      order by vja.to_name is null, vja.to_name, vjot.name, vja.created_at
      limit 200
    "
    @jobs = Job.find_by_sql sql

    render :layout => "aq2-dashboard"
  end

  def technician
    # FROM API/V2/DASHBOARD
    # TODO: MOVE SQL TO MODEL
    sql = "
      select
      j.id, j.user_id, j.state, j.created_at, j.updated_at, j.pc, j.group_id, j.submitted_by,
      vjot.operation_type_id as 'operation_type_id', vjot.name as 'operation_type_name', vjot.category as 'operation_type_category',
      vjassoc.n as 'operation_count',
      vja.assigned_by, vja.by_name, vja.by_login, vja.assigned_to, vja.to_name, vja.to_login, vja.created_at as 'assigned_at'
      from jobs j
      inner join view_job_operation_types vjot on vjot.job_id = j.id
      inner join view_job_associations vjassoc on vjassoc.job_id = j.id
      inner join view_job_assignments vja on vja.job_id = j.id
      where vja.assigned_to=#{current_user.id} and j.pc in (-1,0)
      order by vjot.name, vja.created_at
      limit 200
    "
    @jobs = Job.find_by_sql sql

    render :layout => "aq2-dashboard"
  end

end
