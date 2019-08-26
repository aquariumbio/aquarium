# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do

  # Note: this has to be run with S3 running. So, use docker-compose exec app

  context 'basics' do

    def new_upload

      u = Upload.new

      File.open('app/assets/images/biofab-logo.jpg') do |f|
        u.upload = f
        u.name = 'test file'
        u.save
      end

      u

    end

    it 'can be created' do
      expect { new_upload }.not_to raise_error
    end

    it 'can be associated with a model via a data association' do
      operation = OperationType.last.operations.new
      operation.associate :my_file, 'This is a test file', new_upload
    end

  end

end
