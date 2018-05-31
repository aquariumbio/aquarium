

namespace :rates do

  desc 'Summarize Costs'

  task summary: :environment do

    puts 'Month,Task,Number of tasks,Total materials,Total labor'

    y = 2016
    m = 10

    (1..4).each do |_i|

      start = Date.new(y, m).beginning_of_month

      m += 1
      if m > 12
        m = 1
        y = 2017
      end

      stop = Date.new(y, m).beginning_of_month

      puts start.strftime('%b %d, %Y') + ' - ' + (stop - 1.day).strftime('%b %d, %Y')

      TaskPrototype.all.each do |tp|

        materials = 0.0
        labor = 0.0

        tasks = Task.where(task_prototype_id: tp.id).where('? <= created_at AND created_at < ?', start, stop)

        tasks.each do |task|

          materials += task.accounts.select { |a| a.category == 'materials' }.inject(0) { |sum, a| sum + a.amount }
          labor += task.accounts.select { |a| a.category == 'labor' }.inject(0) { |sum, a| sum + a.amount }

        end

        puts ",#{tp.name},#{tasks.length},#{materials},#{labor}"

      end

    end

  end

end
