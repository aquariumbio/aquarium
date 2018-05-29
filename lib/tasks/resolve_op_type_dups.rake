desc 'Changes duplicate names in OperationTypes'
task rename_optype_duplicates: [:environment] do
  # Find the categories for all operation types
  categories = OperationType.select(:category).group(:category).collect(&:category)
  categories.each do |category|
    # find the duplicate names within the category
    duplicate_names = OperationType.find_by_sql(
      "SELECT t.name FROM operation_types t WHERE t.category = '#{category}' GROUP BY t.name HAVING COUNT(t.name) > 1"
    ).collect(&:name)
    duplicate_names.each do |name|
      puts("\nCategory: \"#{category}\"")
      # collect the operation types with the same name within the category
      deployed = []
      undeployed = []
      op_types = OperationType.where(category: category, name: name)
      op_types.each do |op_type|
        if op_type.deployed
          deployed << op_type
        else
          undeployed << op_type
        end
      end

      # choose an operation type to retain name
      # if there are any deployed, choose from those
      select_list = deployed
      select_list = op_types if deployed.empty?
      selected = select_list.min { |a, b| a.id <=> b.id }
      puts("- Keeping \"#{selected.name}\" (id: #{selected.id})")

      # for the rest, change the name with a counter value
      rename_list = op_types - [selected]
      rename_list.each_with_index do |op_type, index|
        new_name = "#{op_type.name} (duplicate #{index + 1})"
        puts("- Renaming \"#{op_type.name}\" (id: #{op_type.id}) to \"#{new_name}\"")
        op_type.name = new_name
        op_type.save
      end
    end
  end
end
