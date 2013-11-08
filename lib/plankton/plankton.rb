# Changes to Class
require_relative 'meta'

# Tokenizer
require_relative 'tokenizer'

# Parser
require_relative 'parser'
require_relative 'strings'
require_relative 'arguments'
require_relative 'steps'
require_relative 'assignments'
require_relative 'expressions'
require_relative 'statements'
require_relative 'takes'
require_relative 'produces'
require_relative 'log'
require_relative 'controls'
require_relative 'https'
require_relative 'modifies'

# Instructions
require_relative './instructions/instruction'
Dir["#{File.dirname(__FILE__)}/instructions/*_instruction.rb"].each { |file| require_relative file }

