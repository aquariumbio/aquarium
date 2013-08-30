class HTTPInstruction < Instruction

  attr_reader :info_expr

  def initialize info_expr

    super 'http'
    @info_expr = info_expr
    @renderable = false

  end
 
  def bt_execute scope, params

    info = {}

    @info_expr.each do |k,v| 

      if k != :query
        info[k] = scope.substitute v
      else 
        info[:query] = {}
        v.each do |q,w|
          info[:query][q] = scope.substitute w 
        end
      end
    end

    uri = URI(info[:host] + ':' + info[:port] + info[:path])
    uri.query = URI.encode_www_form(info[:query])
    res = Net::HTTP.get_response(uri)

    scope.set info[:status].to_sym, res.code.to_i

    if res.body
      scope.set info[:body].to_sym, res.body
    else
      scope.set info[:body].to_sym, 'error, see code'
    end

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = @type
    log.data = { info: info, code: res.code.to_i }.to_json
    log.save

  end
  
  def to_html 
    info_expr.to_s
  end


end


