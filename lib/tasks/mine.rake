# frozen_string_literal: true

namespace :mine do

  desc 'Mine data for learning'

  # Add primers (id and sequences), fragment ids, fragment stock id, task owner id

  task gibson: :environment do
    data = TaskPrototype.find_by(name: 'Gibson Assembly')
                        .tasks
                        .select { |t| t.status == 'imaged and stored in fridge' || t.status == 'no colonies' }
                        .each do |t|
      d = [t.id,
           t.simple_spec[:fragments]
            .collect do |f|
              s = Sample.find_by(id: f)
              s ? s.properties['Length'].to_i : 0
            end,
           Sample.find_by(id: t.simple_spec[:plasmid]),
           t.status == 'imaged and stored in fridge' ? 1 : 0]
      puts "#{d[0]}, #{d[2] ? d[2].id : 0}, #{d[3]}, #{d[1].join(', ')}"
    end
  end

end
