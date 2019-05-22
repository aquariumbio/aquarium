# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do

  before { skip('need to resolve problem accessing s3 within docker') }

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
      u = new_upload
    end

    it 'can be associated with a model via a data association' do
      operation = OperationType.last.operations.new
      operation.associate :my_file, 'This is a test file', new_upload
    end

  end

end
