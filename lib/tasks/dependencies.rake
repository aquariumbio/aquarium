namespace :dependencies do 

  desc 'Gather dependency data from database'

  task libraries: :environment do 
    
    libraries = Library.select(:id, :name, :category).order(category: :asc, name: :asc)

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
              current_library = []
              current_library << (category_and_name)
              methods = get_methods(library)
              methods.each do |method|
                if protocol_content.include?(method) 
                  current_library << method 
                end
              end
            libraries_cited << current_library 
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

    op_types[0..5].each do |op_type| 
      category_and_name = (get_category_key(op_type)) 
      protocol_content = op_type.protocol.content # get code for protocols 

      developers = get_developers(op_type.protocol) # get developers who worked on code 

      libraries_cited = check_libraries(protocol_content, libraries) #get libraries that were cited  

      included = (libraries_cited.map { |x| x.split(pattern = /\//)[0] }).count(op_type.category)

      print "#{category_and_name},#{libraries_cited.flatten},#{libraries_cited.length},#{included},#{libraries_cited.length - included},#{developers}\n"
    end 
  end 
end 
    # Remove libraries that we aren't using 
    # we have 81 libraries that are never used in a deployed protocol and 63 that are  
    #libraries_to_optypes.delete_if {|lib, optype| optype.length == 0} 

