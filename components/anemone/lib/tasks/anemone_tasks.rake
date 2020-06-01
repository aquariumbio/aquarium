namespace :anemone do

  class CreateAnemoneWorker < ActiveRecord::Migration
    def change
      create_table :workers do |t|
        t.string :name
        t.string :message
        t.string :status
        t.timestamps
      end
    end
  end

  desc 'Migrates the DB so it has the worker model'
  task setup: :environment do
    unless ActiveRecord::Base.connection.table_exists? 'worker'
      m = CreateAnemoneWorker.new
      m.change
    end
  end

end
