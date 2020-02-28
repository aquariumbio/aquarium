namespace :dependencies do 

  desc 'Gather dependency data from database'

  task libraries: :environment do 
    
    # Get Library Names and Categories -- 151  <Library id: 2, name: "Handling", category: "Hydra Transgenics">
    libraries = Library.select(:id, :name, :category).order(category: :asc, name: :asc)
    # Get names and categories for deployed operations <OperationType id: 15, name: "Run Gel", category: "Cloning">
    op_types = OperationType.select(:id, :name, :category).where(:deployed => true)

    users = User.select(:id, :name).all

    def get_category_key(code)
      return code.category + '/' + code.name 
    end 

    def check_libraries(protocol_content, libraries) 
      libraries_cited = []
      libraries.each do |library|
        category_and_name = get_category_key(library)

        if protocol_content.include?(category_and_name)
              libraries_cited << (category_and_name)
              methods = get_methods(library) 
              methods.each do |method|
                if protocol_content.include?(method) 
                    puts "#{method}"
                end
              end
        end
      end 
        return libraries_cited
    end 

    def get_methods(library)
      library.source.content.scan(/\s{2,}def\s+([A-Za-z0-9_\.]*)/).flatten!
    end
    
    def get_developers(protocol)
      user_names = []
      protocol.versions.each do |version|
        if version.user_id != nil
          user_names << User.select(:name).find(version.user_id).name 
        end 
      end
      return user_names.uniq! 
    end 

    # Get names and categories for deployed operaions <OperationType id: 15, name: "Run Gel", category: "Cloning">
    op_type_data = {}
    op_types[0..5].each do |op_type| 
      category_and_name = (get_category_key(op_type)) 

      protocol_content = op_type.protocol.content # get code for protocols 
      developers = get_developers(op_type.protocol) # get developers who worked on code 

      libraries_cited = check_libraries(protocol_content, libraries) #get libraries that were cited  

      included = (libraries_cited.map { |x| x.split(pattern = /\//)[0] }).count(op_type.category)
      #methods_included = get_methods(library) 
      print "#{category_and_name},#{libraries_cited},#{libraries_cited.length},#{included},#{libraries.length - included},#{developers}\n"
    end 

    # make hash with optypes as keys and {libraries => methods} as values 
    optypes_to_libraries = {}
    op_types_to_protocol_code.each do |optype, code|
      libraries_to_methods.each do |library, methods|
        if code.include?(library)
          if optypes_to_libraries.keys.include?(optype)
              optypes_to_libraries[optype][library] = methods  
          else 
              optypes_to_libraries[optype] = {library => methods}  
          end
        end
      end
    end
    
    #library_code.keep_if{|k, v| libraries_to_optypes.keys.include?(k)}
    # Create hash with library as the key, protocols that cite that library as the value 
    libraries_to_optypes = {}
    libraries.each do |library|
      optypes = []
      op_types_to_protocol_code.each do |optype, code| 
        if code.include?(library.category + "/" + library.name)
          optypes << optype
        end
      end
      libraries_to_optypes[library.category + "/" + library.name] = optypes 
    end 
    
    # count total number of times library is cited, times it's cited within its own category, 
    # and times it's cited out of it's category
    # append count to hash  
    # Get Code for all operation types. Get users.  
    code = Code.select(:id, :parent_id, :user_id).where(:parent_class => 'OperationType')


  end 
end 
    # Remove libraries that we aren't using 
    # we have 81 libraries that are never used in a deployed protocol and 63 that are  
    #libraries_to_optypes.delete_if {|lib, optype| optype.length == 0} 

    # Make list of methods, remove duplicates  
    # methods_list = libraries_to_methods.values.flatten.uniq 

#    "Cloning/Assemble Plasmid" => ["Cloning Libs/Cloning", "Cloning Libs/Special Days", "Standard Libs/Feedback"]
    #libraries_to_optypes.each do |library, op_types|
    #  if op_types.length > 0 
    #    op_types.each do |op_type|
    #      optypes_to_libraries[op_type] << library 
    #    end 
    #  end
    #end
    #

    library_code = {} 
    libraries.each do |library| 
      library_code[library.category + "/" + library.name] = library.source.content 
    end
   
