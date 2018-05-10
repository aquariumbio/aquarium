desc "Changes duplicate names in OperationTypes"
task :rename_optype_duplicates => [:environment] do
    categories = OperationType.select(:category).group(:category).collect{|op_type| op_type.category}
    categories.each do |category|
        duplicate_names = OperationType.find_by_sql("SELECT t.name FROM operation_types t WHERE t.category = '#{category}' GROUP BY t.name HAVING COUNT(t.name) > 1").collect{|op_type| op_type.name}
        duplicate_names.each do |name|
            op_types = OperationType.where({category: category, name: name})
            op_types.each do |op_type|
                puts("category: #{op_type.category}, name: #{op_type.name}, id: #{op_type.id}, deployed: #{op_type.deployed}")
            end
        end
    end
end

