# frozen_string_literal: true

require 'erb'
require 'fileutils'

module Aquadoc
  class Local
    def initialize(config, categories, opts = {})
      @opts = opts
      @config = config
      @repo = nil
      @categories = categories
    end

    def run
      aquadoc = Render.new(self, @config, @categories)
      FileUtils.mkdir_p 'docs'
      FileUtils.mkdir_p 'docs/operation_types'
      FileUtils.mkdir_p 'docs/libraries'
      FileUtils.mkdir_p 'docs/sample_types'
      FileUtils.mkdir_p 'docs/object_types'
      FileUtils.mkdir_p 'docs/css'
      FileUtils.mkdir_p 'docs/js'
      aquadoc.make(@opts)
    end

    def write(path, content)
      puts '--> ' + 'docs/' + path
      File.write('docs/' + path, content)
    end

    def authorized
      true
    end
  end
end
