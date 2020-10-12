# frozen_string_literal: true

# typed: strict

Rails.application.routes.draw do
  get 'workers/:id' => 'anemone/workers#show'
end
