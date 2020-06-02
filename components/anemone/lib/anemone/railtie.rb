# frozen_string_literal: true

# typed: strong

class Anemone::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/anemone_tasks.rake'
  end
end
