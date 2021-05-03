# frozen_string_literal: true

# typed: strict

require 'anemone/version'
require 'anemone/model'
require 'anemone/railtie' if defined?(Rails)

module Anemone
  class Engine < Rails::Engine; end
end
