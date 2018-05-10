desc "Changes duplicate names in OperationTypes"
task :rem_optype_dups => [:environment] do
    duplicates = OperationType.find_by_sql(
        "SELECT t.name FROM operation_types t GROUP BY t.name HAVING COUNT(t.name) > 1")
    duplicates.each do |duplicate|
        puts(duplicate.name)
        OperationType.where(name: duplicate.name).each do |op_type|
            # the goal here would be to rename any operation types with 
            # duplicate names within a category to allow a unique index to be
            # created.
            # However, current model doesn't allow this since versions occur as
            # different records.
            puts("category: #{op_type.category}, name: #{op_type.name}")
        end
    end
end