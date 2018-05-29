# frozen_string_literal: true

namespace :ci do

  require 'rubocop/rake_task'

  def changed_files
    cmd = %q( git diff --name-only --diff-filter=ACMRTUXB \
    $(git merge-base HEAD master) \
    | egrep '\.rake$|\.rb$' )
    diff = `#{cmd}`
    diff.split("\n")
  end

  def patterns_for_changed_files
    # always include the ci.rake file, if the patterns is empty it runs everything
    patterns = ['lib/tasks/ci.rake']
    patterns += changed_files
  end

  desc 'Run RuboCop on the entire project'
  RuboCop::RakeTask.new('rubocop') do |task|
    task.fail_on_error = true
  end

  desc 'Run RuboCop on the project based on git diff'
  RuboCop::RakeTask.new('rubocop_changed') do |task|
    task.patterns = patterns_for_changed_files
    task.fail_on_error = true
  end

end
