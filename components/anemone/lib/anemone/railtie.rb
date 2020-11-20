# frozen_string_literal: true

# typed: strict

class Anemone::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/anemone_tasks.rake'
  end
end
