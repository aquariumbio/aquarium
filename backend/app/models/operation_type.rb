# frozen_string_literal: true

# operation_types table
class OperationType < ActiveRecord::Base
  def self.operation_types(category, status)
    sql = "
      select ot.id, ot.name, count(*) as 'n'
      from operation_types ot
      inner join operations o on o.operation_type_id = ot.id
      where ot.category = ? and o.status = ?
      group by ot.id
      order by ot.name
    "
    operation_types = OperationType.find_by_sql [sql, category, status]
  end
end
