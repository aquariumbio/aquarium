# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonController::JsonQueryResult do
  it 'should fail on bad model' do
    expect { JsonController::JsonQueryResult.create_from(model: 'baad') }.to raise_error(NameError)
  end

  it 'should return nothing if valid model with no method' do
    expect(JsonController::JsonQueryResult.create_from(model: 'Job')).to be_nil
  end

  # TODO: all of this job stuff depends on something being in the database, clean this up
  it 'all should return a non-nil relation' do
    expect(JsonController::JsonQueryResult.create_from(model: 'Job', method: 'all')).not_to be_nil
  end

  it 'include bad association' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', include: 'bad') }.not_to raise_error
  end

  it 'include non-association method' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', include: 'operations') }.not_to raise_error
  end

  it 'include non-association name with association' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', include: %w[operations user]) }.not_to raise_error
  end

  it 'include manager query' do
    expect { JsonController::JsonQueryResult.create_from(model: 'Job', include: [{ operations: { include: :operation_type } }, :user]) }.not_to raise_error
  end

  it 'manager query should return something without crashing' do
    expect(JsonController::JsonQueryResult.create_from(model: 'Job', method: 'where', arguments: 'pc >= 0', options: { offset: -1, limit: -1, reverse: false }, include: [{ operations: { include: :operation_type } }, :user])).not_to be_nil
  end

  it 'invoice query should not crash' do
    expect(JsonController::JsonQueryResult.create_from(model: 'AccountLog', method: 'where', arguments: { row1: [72, 73] }, options: { offset: -1, limit: -1, reverse: false }, include: 'user')).to be_empty
    expect(JsonController::JsonQueryResult.create_from(model: 'AccountLog', method: 'where', arguments: { row1: [59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71] }, options: { offset: -1, limit: -1, reverse: false }, include: 'user')).not_to be_empty
  end

end
