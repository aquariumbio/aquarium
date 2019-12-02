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

    let!(:test_user) { create(:user) }
    let(:dummy_sample_type) { create(:sample_type, name: 'DummySampleType') }
    let(:dummy_sample) { create(:sample, name: 'DummySample', sample_type: dummy_sample_type) }
    let(:dummy_object_type) { create(:object_type, name: 'DummyObjectType') }
    let(:io_protocol) do
      create(
        :operation_type,
        name: 'io protocol',
        category: 'testing',
        protocol: 'class Protocol; def main; show { title \'blah\'; note operations.first.input(\'blah\').item.id }; end; end',
        test: 'class ProtocolTest < ProtocolTestBase; def setup; add_random_operations(1); end; def analyze; assert_equal(@backtrace.last[:operation], \'complete\'); end; end;',
        inputs: [{ name: 'blah', sample_type: 'DummySampleType', object_type: 'DummyObjectType' }],
        user: test_user
      )
    end
    let!(:dummy_item) do
      create(:item, sample_id: dummy_sample.id, object_type_id: dummy_object_type.id)
    end
    it 'can be associated with a model via a data association' do
      operation = io_protocol.operations.create(status: 'waiting', user_id: test_user.id)
      operation.associate :my_file, 'This is a test file', new_upload
    end

  end

end
