namespace :data do

  desc 'Upgrade data json fields to DataAssociations'

  def upgrade item
    
    begin

      obj = JSON.parse item.data

      obj.each do |k,v|
        item.associate k, v
      end

    rescue Exception => e

      item.notes = item.data if item.data

    end

  end

  task :upgrade => :environment do 
    samples = Sample.where project: "LABW16"
    items = samples.collect { |s| s.items }.flatten
    puts "Upgrading #{items.length} items"
    items.each do |i|
      upgrade i
    end
  end

  task :downgrade => :environment do
    puts "Deleting #{DataAssociation.count} data associations"
    DataAssociation.destroy_all
  end

end
