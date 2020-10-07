# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperationTypesController, type: :controller do
  let!(:test_user) { create(:user) }
  let(:frontend_message_json) {
    {
      'model' => { 'model' => 'OperationType', 'record_methods' => {}, 'record_getters' => {} },
      'name' => 'testing_protocol',
      'category' => 'Misc.',
      'deployed' => false,
      'changed' => true,
      'field_types' => nil,
      'protocol' => { 'model' => { 'model' => 'Code', 'record_methods' => {}, 'record_getters' => {} }, 'name' => 'protocol', 'content' => '# typed: false\n# frozen_string_literal: true\n\n# This is a default, one-size-fits all protocol that shows how you can\n# access the inputs and outputs of the operations associated with a job.\n# Add specific instructions for this protocol!\n\nclass Protocol\n\n  def main\n\n    operations.retrieve.make\n\n    tin  = operations.io_table "input"\n    tout = operations.io_table "output"\n\n    show do\n      title "Input Table"\n      table tin.all.render\n    end\n\n    show do\n      title "Output Table"\n      table tout.all.render\n    end\n\n    operations.store\n\n    {}\n\n  end\n\nend\n', 'rid' => 38 },
      'cost_model' => {'model' => {'model' => 'Code', 'record_methods' => {}, 'record_getters' => {}}, 'name' => 'cost_model', 'content' => 'def cost(_op)\n  { labor: 0, materials: 0 }\nend', 'rid' => 39},
      'precondition' => {'model' => {'model' => 'Code', 'record_methods' => {}, 'record_getters' => {}}, 'name' => 'precondition', 'content' => 'def precondition(_op)\n  true\nend', 'rid' => 40},
      'documentation' => {'model' => {'model' => 'Code', 'record_methods' => {}, 'record_getters' => {}}, 'name' => 'documentation', 'content' => 'Documentation here. Start with a paragraph, not a heading or title, as in most views, the title will be supplied by the view.', 'rid' => 41},
      'rid' => 42,
      'stats' => {},
      'data_associations' => nil,
      'operation_type' => {'deployed' => false, 'name' => 'blah blah', 'category' => 'Misc.'}
    }
  }

  token_name = "remember_token_#{Bioturk::Application.environment_name}".to_sym

  describe 'creating operation types' do

    it 'should accept operation type param' do
      cookies[token_name] = User.find(1).remember_token

      post :create, frontend_message_json

      response_hash = JSON.parse(@response.body, symbolize_names: true)
      expect(response_hash.keys).to eq([:id, :name, :category, :deployed, :on_the_fly, :created_at, :updated_at, :field_types, :protocol, :precondition, :cost_model, :documentation, :test])
    end
  end
end
