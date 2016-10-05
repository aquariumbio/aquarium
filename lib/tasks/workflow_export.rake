
namespace :workflow do

  desc 'Export Workflow'

  task :export => :environment do

    str = OperationType.find_by_name("PCR").export.to_json

    f = File.open('tmp/workflow.json', "w+")
    f.write(str)
    f.close

    f = File.open('tmp/workflow.json', "rb")
    x = f.read
    f.close

    ob = JSON.parse(x,symbolize_names: true)

    OperationType.import ob

  end

end
