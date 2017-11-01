namespace :code do

  desc 'Fix Code Version Links'

  task :fix_versions => :environment do 

    OperationType.all.each do |ot|

      versions = Code.where(parent_class: "OperationType", parent_id: ot.id, name: "protocol")
      num_childless = versions.select { |c| c.child_id == nil }.length

      if num_childless >= 1

        puts "Fixing versions for #{ot.name} which has #{num_childless} childless versions out of #{versions.length}"

        (0..versions.length-2).each do |i|
          versions[i].child_id = versions[i+1].id
          versions[i].save
          puts "     #{i}:\t#{versions[i].id}\t#{versions[i].created_at}\t-->\t#{versions[i+1].id}"
        end

        puts "   Current version of protocol for #{ot.name} is now #{ot.protocol.id}"        

      end

    end

  end

end