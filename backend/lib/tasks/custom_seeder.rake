#lib/tasks/custom_seeder.rake
namespace :db do
  namespace :seed do
    Dir[File.join(Rails.root, 'db', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').intern
      task task_name => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end
end

# USAGE:
# docker-compose exec backend env RAILS_ENV=test rake db:seed:test_seeds
