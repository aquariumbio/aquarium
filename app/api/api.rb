class Api

  attr_reader :params, :user

  include ApiLogin
  include ApiFind
  include ApiCreate
  include ApiDrop
  include ApiSubmit

  def initialize params
    @params = symbolize params
    @errors = []
    @warnings = []
    @rows = []
    @user = nil
  end

  def symbolize hash
    hash.inject({}) { |result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize value
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end

  def error?
    @errors.length > 0
  end

  def warning?
    @warnings.length > 0
  end

  def error e
    @errors.push e
  end

  def warn w
    @warnings.push w
  end

  def add r
    @rows += r
  end

  def run

    if login

      if params[:run] && params[:run][:method]
        begin
          direct params[:run][:method], params[:run][:args]
        rescue Exception => e
          error "Could not execute request: #{e}, #{e.backtrace.first}"
        end
      else
        warn "No run section found"
      end

    end

    if error?
      return { result: "error", errors: @errors }
    else
      return { result: "ok", warnings: @warnings, rows: @rows }
    end

  end

  def direct method, args

    routes = { "find"   => method(:find),
               "create" => method(:create),
               "submit" => method(:submit),
               "drop" => method(:drop) }

    if routes[method]
      routes[method].call(args)
    else
      warn "No valid methods found"
    end

  end

end
