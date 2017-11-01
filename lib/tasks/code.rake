namespace :code do

  desc 'Fix Code Version Links'

  task :fix_versions => :environment do 

    OperationType.all.each do |ot|

     ["protocol", "precondition", "cost_model", "documentation", "source"].each do |name|

        versions = Code.where(parent_class: "OperationType", parent_id: ot.id, name: name)
        num_childless = versions.select { |c| c.child_id == nil }.length

        if num_childless > 1

          puts "Fixing #{name} versions for #{ot.name} which has #{num_childless} childless versions out of #{versions.length}"

          (0..versions.length-2).each do |i|
            versions[i].child_id = versions[i+1].id
            versions[i].save
            puts "     #{i}:\t#{versions[i].id}\t#{versions[i].created_at}\t-->\t#{versions[i+1].id}"
          end

          puts "   Current version of #{name} for #{ot.name} is now #{ot.code(name).id}"

        end

      end

    end

    Library.all.each do |lib|

      versions = Code.where(parent_class: "Library", parent_id: lib.id, name: "source")
      num_childless = versions.select { |c| c.child_id == nil }.length

      if num_childless > 1

        puts "Fixing source versions for #{lib.name} which has #{num_childless} childless versions out of #{versions.length}"

        (0..versions.length-2).each do |i|
          versions[i].child_id = versions[i+1].id
          versions[i].save
          puts "     #{i}:\t#{versions[i].id}\t#{versions[i].created_at}\t-->\t#{versions[i+1].id}"
        end

        puts "   Current version of source for #{lib.name} is now #{lib.code('source').id}"

      end

    end

  end

end