# frozen_string_literal: true

module Plankton

  class StepInstruction < Instruction

    attr_reader :statements, :evaluation, :has_image

    def initialize(stmts, options = {})

      @statements = stmts
      @evaluation = []
      @has_image = false

      @renderable = true
      super 'step', options

    end

    def evaluate_input_statements(scope, _params, s)

      e = { type: :input, parts: [] }

      s[:parts].each do |p|

        q = { flavor: p[:flavor], var: p[:var], type: p[:type] }

        description = scope.evaluate(p[:description])
        description = description.to_s if description.class != String
        q[:description] = description

        q[:choices] = scope.evaluate(p[:choices]) if p[:flavor] == :select

        e[:parts].push q

      end

      e

    end

    def evaluate_foreach(scope, params, s)

      e = { type: s[:type], statements: [] }
      list = scope.evaluate(s[:list])

      raise "#{e[:list]} is not an array" if list.class != Array

      scope.push

      list.each do |el|
        scope.set(s[:iterator], el)
        s[:statements].each do |t|
          e[:statements].push(evaluate_statement(scope, params, t))
        end
      end

      scope.pop

      e

    end

    def evaluate_statement(scope, params, s)

      e = { type: s[:type] }

      case s[:type]

      when :description, :note, :warning, :bullet, :check

        value = scope.evaluate(s[:expr])
        value = value.to_s if value.class != String
        e[:value] = value

      when :image
        @has_image = true
        name = scope.evaluate(s[:expr])
        value = "#{Bioturk::Application.config.image_server_interface}#{name}"

        value = value.to_s if value.class != String
        e[:value] = value

      when :timer

        spec = { hours: 0, minutes: 0, seconds: 0 }
        e[:value] = scope.evaluate(s[:expr])

      when :table

        value = scope.evaluate(s[:expr])

        raise 'Expression for table is not an array of arrays' if value.class != Array

        unless value.empty?
          len = value[0].length
          value.each do |row|
            raise 'Expression for table is not an array of equal length arrays' if row.length != len
          end
        end

        e[:value] = value

      when :input
        e = evaluate_input_statements scope, params, s

      when :foreach
        e = evaluate_foreach scope, params, s

      end

      e

    end

    def pre_render(scope, params)

      @evaluation = []

      @statements.each do |s|
        @evaluation.push(evaluate_statement(scope, params, s))
      end

    end

    def process_inputs(e); end

    def bt_execute(scope, params)

      log_data = {}

      pre_render scope, params

      (@evaluation.select { |s| s[:type] == :input }).each do |input|
        input[:parts].each do |g|

          sym = g[:var].to_sym

          if g[:type] == 'number' && params[g[:var]].to_i == params[g[:var]].to_f
            scope.set sym, params[g[:var]].to_i
          elsif g[:type] == 'number'
            scope.set sym, params[g[:var]].to_f
          else
            scope.set sym, params[g[:var]]
          end

          log_data[sym] = scope.get sym

        end
      end

      unless log_data.empty?
        log = Log.new
        log.job_id = params[:job]
        log.user_id = scope.stack.first[:user_id]
        log.entry_type = 'INPUT'
        log.data = { pc: @pc, inputs: log_data }.to_json
        log.save
      end

    end

    def to_s
      "step\n  #{@statements}"
    end

    def html
      "<b>step</b>: #{@statements}"
    end

  end

end
