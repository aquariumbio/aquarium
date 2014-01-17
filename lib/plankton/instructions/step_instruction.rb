module Plankton

  class StepInstruction < Instruction

    attr_reader :parts

    def initialize part_exprs, options = {}

      @part_exprs = part_exprs
      @renderable = true
      super 'step', options

      # TERMINAL
      @parts = part_exprs

    end

    # RAILS ################################################################################

    def description 
      str = ""
      @parts.each do |a|
        str = a[:description] if a.has_key?(:description)
      end
      str
    end

    def note
      str = ""
      @parts.each do |a|
        str = a[:note] if a.has_key?(:note)
      end
      str
    end

    def image
      str = ""
      @parts.each do |a|
        if a.has_key?(:image)
          str = "http://bioturk.ee.washington.edu:3012/bioturk/image?name=#{a[:image]}"
        end
      end
      str
    end

    def timer
      spec = { hours: 0, minutes: 0, seconds: 0 }
      @parts.each do |a|
        if a.has_key?(:timer)
          spec.merge! a[:timer]
        end
      end
      spec
    end

    def warnings
      w = []
      @parts.each do |a|
        w.push a[:warning] if a.has_key?(:warning)
      end
      w
    end

    def getdatas
      g = []
      @parts.each do |a|
        g.push a[:getdata] if a.has_key?(:getdata)
      end
      g
    end

    def selects
      g = []
      @parts.each do |a|
        g.push a[:select] if a.has_key?(:select)
      end
      g
    end

    def pre_render scope, params

      @parts = []

      @part_exprs.each do |a|

        a.each do |k,v|

          begin

            if k == :getdata
              @parts.push( getdata: { 
                 var: v[:var], 
                 type: v[:type], 
                 description: scope.substitute( v[:description] ) } )

            elsif k == :select
              choice_evals = scope.evaluate v[:choices]
              @parts.push( select: { 
                 var: v[:var], 
                 type: v[:type],
                 description: scope.substitute( v[:description] ), 
                 choices: choice_evals } )

            else
              @parts.push( k => scope.substitute( v ) )

            end

          rescue Exception => e
            raise "In step: " + e.to_s
          end

        end

      end

    end

    def bt_execute scope, params

      log_data = {}

      getdatas.each do |g|
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

      selects.each do |s|
        sym = s[:var].to_sym
        if s[:type] == 'number' && params[s[:var]].to_i == params[s[:var]].to_f
          scope.set sym, params[s[:var]].to_i
        elsif s[:type] == 'number'
          scope.set sym, params[s[:var]].to_f
        else
          scope.set sym, params[s[:var]]
        end
        log_data[sym] = scope.get sym
      end

      unless log_data.empty?
        log = Log.new
        log.job_id = params[:job]
        log.user_id = scope.stack.first[:user_id]
        log.entry_type = 'GETDATA'
        log.data = {pc: @pc, getdatas: log_data}.to_json
        log.save
      end

    end

    def html
      "<b>step</b>: " + description
    end

  end

end
