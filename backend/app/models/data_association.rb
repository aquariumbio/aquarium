# frozen_string_literal: true

# data_associations table
class DataAssociation < ActiveRecord::Base
  # get data_associations for operation
  def self.data_associations(operation_id)
    sql = "
      select id, object
      from data_associations
      where parent_class = 'Operation' and parent_id = #{operation_id}
      order by updated_at desc, id desc
    "
    data_associations = DataAssociation.find_by_sql sql
  end
end
