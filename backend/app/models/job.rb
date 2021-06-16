# frozen_string_literal: true

# jobs table
class Job < ActiveRecord::Base
  # Get job counts by job status (regardless of operation status)
  #
  # return job counts by job status (regardless of operation status)
  def self.counts_by_job_status
    # Calculate counts by job.pc
    # NOTE: By definition (internal, not configurable)
    # - pc = -2: Completed
    # - pc = -1: Not Started
    # - pc = 0: Running
    # NOTE: no check on whether operation type is deployed
    sql = "
      select j.pc, count(*) as 'count'
      from jobs j
      inner join view_job_associations ja on ja.job_id = j.id
      group by j.pc
    "
    temp = Job.find_by_sql sql

    # Calculate "finished" jobs = jobs completed ( jobs that have operations, regardless of operation status)
    # Calculate "not finished" jobs = jobs not completed ( jobs that have operations, regardless of operation status)
    finished = 0
    not_finished = 0
    temp.each do |t|
      if t.pc == -2
        finished += t.count
      else
        not_finished += t.count
      end
    end

    # Calculate "assigned not finished" jobs = jobs assigned not completed (regardless of operation status)
    sql = "select count(*) from view_job_assignments where pc != -2"
    assigned_not_finished = Job.count_by_sql sql

    # return job counts by job status
    return {
      assigned: assigned_not_finished,
      unassigned: (not_finished - assigned_not_finished),
      finished: finished
    }
  end

  # Get operation counts by operation_type where [ status = 'pending' or status = 'error' ] and operation_type is deployed (regardless of job status)
  #
  # return operation counts by operation_type
  def self.counts_by_operation_type
    # calculate operation counts

    # active operation_types (categories)
    sql = "
      select ot.category, count(*) as 'count'
      from operations o
      inner join operation_types ot on ot.id = o.operation_type_id
      where (o.status = 'pending' or o.status = 'error')
      and ot.deployed = 1
      group by ot.category
      order by category
    "
    categories = Operation.find_by_sql sql

    list = []
    categories.each do |c|
      # escape any single quotes in category names
      list << c.category.gsub("'", "\\\\'")
    end
    puts list.join(',')

    # inactive operation_types (categories)
    sql = "
      select distinct category from operation_types
      where category not in ( '#{list.join("','")}' )
      order by category
    "
    inactive_categories = OperationType.find_by_sql sql

    # populate counts by active operation type
    active = {}
    categories.each do |c|
      active.merge!({ c.category => c.count })
    end

    # list inactive operation types
    inactive = []
    inactive_categories.each do |i|
      inactive << i.category
    end

    return { active: active, inactive: inactive }
  end

  # Get unassigned jobs that have operations and that are not finished
  #
  # return unassigned jobs
  def self.unassigned_jobs
    # custom SQL query
    # include protocol + job id + operations count + created date
    sql = "
      select jot.*, nn.n as 'operations_count'
      from view_job_operation_types jot
      inner join view_job_associations nn on nn.job_id = jot.job_id
      left join view_job_assignments ja on ja.job_id = jot.job_id
      where jot.pc != -2
      and ja.id is null
      order by jot.created_at desc
    "
    unassigned = Job.find_by_sql sql
  end

  # Get assigned jobs that have operations and that are not finished
  #
  # return assigned jobs
  def self.assigned_jobs
    # custom SQL query
    # include assigned to + priority (future) + protocol + job id + operations count + status + progress (future) + started
    sql = "
      select ja.to_name, ja.to_login, jot.*, nn.n as 'operations_count'
      from view_job_operation_types jot
      inner join view_job_associations nn on nn.job_id = jot.job_id
      inner join view_job_assignments ja on ja.job_id = jot.job_id
      where jot.pc != -2
      order by jot.created_at desc
    "
    assigned = Job.find_by_sql sql
  end

  # Get finished jobs that have operations
  #
  # @param seven_days [Boolean] flag for jobs finished in last 7 days
  # return finished jobs
  def self.finished_jobs(seven_days)
    # calculate time if seven_days flag is set
    ands = ""
    if seven_days
      # IMPORTANT: Need to see what docker is doing with the timezone. Running this locally Ruby seems to think we are on Eastern Time.
      # 7 days ago in current time zone
      temp = Time.now - 7.days

      # beginning of the day 7 days ago in UTC time
      temp = Time.new(temp.year, temp.month, temp.day, 0, 0, 0, temp.utc_offset).in_time_zone('UTC')

      ands += "and jot.updated_at >= '#{temp.to_s[0, 19]}'"
    end

    # custom SQL query
    # include assigned to + assigned date + started + finished + protocol + job id + operations count
    sql = "
      select ja.to_name, ja.to_login, ja.created_at as 'assigned_date', jot.*, nn.n as 'operations_count'
      from view_job_operation_types jot
      inner join view_job_associations nn on nn.job_id = jot.job_id
      left join view_job_assignments ja on ja.job_id = jot.job_id
      where jot.pc = -2 #{ands}
      order by jot.updated_at desc
      limit 100
    "
    finished = Job.find_by_sql sql
  end
end
