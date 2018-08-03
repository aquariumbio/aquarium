require 'rails_helper'

RSpec.describe Upload, type: :model do

  context 'basics' do

    def new_upload

      u = Upload.new

      File.open("app/assets/images/biofab-logo.jpg") do |f|
        puts f
        u.upload = f
        u.name = "test file"
        u.save
      end

      u

    end

    it 'can be created' do

      u = new_upload
      puts "New upload info:"
      puts "  name = #{u.name}"
      puts "  size = #{u.size}"
      puts "  url = #{u.url}"
      puts "  export = #{u.export}"

    end

    it 'can be associated with a model via a data association' do
      operation = OperationType.last.operations.new
      operation.associate :my_file, "This is a test file", new_upload
      puts "Url for upload associated with Operation: #{operation.upload(:my_file).url}"
    end

  end

end
