class ReleaseInstruction < Instruction

  attr_reader :expr, :item_list

  def initialize(expr)

    @expr = expr
    @renderable = true
    super 'release (deprecated)'

  end

  # RAILS ###########################################################################################

  def pre_render(scope, _params)

    begin
      @item_list = scope.evaluate @expr
    rescue Exception => e
      raise 'In <release>: Could not evaluate object list (' + @expr + '): ' + e.message
    end

    raise 'In <release>: item list evaluated to non array (' + @expr + '): ' unless @item_list && @item_list.class == Array

    @item_list.each do |item|
      raise 'Release error: %{item_list} does not appear to quack like an item.' unless item[:id] && item[:name]
    end

  end

  def bt_execute(scope, params)

    pre_render scope, params
    i = 0
    log_data = []

    @item_list.each do |item|

      m = params["method_#{i}"]
      i += 1
      x = Item.find_by_id(item[:id])
      raise 'no such item:' + item[:name] unless x

      case m

      when 'return'
        x.inuse -= 1

      when 'dispose'
        x.inuse -= 1
        x.quantity -= 1

      else
        raise 'unknown method in release'

      end

      x.save
      log_data.push object_type: item[:name], item_id: item[:id], method: m

    end

    log = Log.new
    log.job_id = params[:job]
    log.user_id = scope.stack.first[:user_id]
    log.entry_type = 'RELEASE'
    log.data = { pc: @pc, objects: log_data }.to_json
    log.save

  end

  def html
    "<b>release</b>: #{@expr}"
  end

  # TERMINAL ########################################################################################

  def render(scope)

    @pi = scope.evaluate @expr
    # TODO: check that @pi is a pdl_item

    if !@pi.is_a?(Array)
      nm     = @pi.object[:name]
      loc    = @pi.item[:location]
      method = @pi.object[:release_description]
      release_method = @pi.object[:release_method]
      length = 1
    else
      nm     = @pi[0].object[:name]
      loc    = @pi[0].item[:location]
      method = @pi[0].object[:release_description]
      release_method = @pi[0].object[:release_method]
      length = @pi.length
    end

    case release_method

    when 'return'
      puts "Please return the #{length} #{nm} taken from #{loc}."
      puts "  Details: #{method}"
      print 'Press [ENTER] when finished: '

    when 'dispose'
      puts "Please dispose of the #{length} #{nm} taken from #{loc}."
      puts "  Details: #{method}"
      print 'Press [ENTER] when finished: '

    when 'query'
      puts "Please specify whether the #{length} #{nm} taken from #{loc} will be (1) returned or (2) disposed of."
      puts "  Details: #{method}\n\n"
      print 'Enter (1) if you returned it or (2) if you disposed of it: '

    end

  end

  def execute(_scope)

    input = gets

    if !@pi.is_a?(Array)
      release_method = @pi.object[:release_method]
      length = 1
    else
      release_method = @pi[0].object[:release_method]
      length = @pi.length
    end

    method = if release_method == 'query'
               if input.to_i == 1
                 'return'
               else
                 'dispose'
                        end
             else
               release_method
             end

    if !@pi.is_a?(Array)
      liaison 'release', id: @pi.item[:id], method: method, quantity: 1
    else
      count = 0
      while count < length
        liaison 'release', id: @pi[count].item[:id], method: method, quantity: 1
        count += 1
      end

    end

  end

end
