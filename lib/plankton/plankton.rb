# frozen_string_literal: true

# Language Tools
require_relative '../lang/lang'

# Parser
require_relative 'parser'
require_relative 'strings'
require_relative 'arguments'
require_relative 'steps'
require_relative 'assignments'
require_relative 'statements'
require_relative 'takes'
require_relative 'produces'
require_relative 'log'
require_relative 'inputs'
require_relative 'controls'
require_relative 'functions'
require_relative 'https'
require_relative 'modifies'
require_relative 'includes'
require_relative 'stop'

# Instructions
require_relative './instructions/instruction'
Dir["#{File.dirname(__FILE__)}/instructions/*_instruction.rb"].each { |file| require_relative file }
