class ReleaseInstruction < Instruction

  attr_reader :expr, :object_list

  def initialize expr

    @expr = expr
    @renderable = true
    super 'release'

  end


  # RAILS ###########################################################################################

  def pre_render scope, params

    begin
      @object_list = scope.evaluate @expr
    rescue Exception => e
      raise "In <release>: Could not evaluate object list (" + @expr + "): " 
    end

    unless @object_list 
      raise "In <release>: object list evaluated to nil (" + @expr + "): " 
    end

    @object_list.each do |object|
      unless object[:object] && object[:item]
        raise "Release error: %{object_list} does not appear to quack like an object."
      end
    end

  end

  def bt_execute scope, params

    pre_render scope, params
    i = 0

    @object_list.each do |pi|

      m = params["method_#{i}"]
      x = Item.find_by_id(pi[:item][:id])
      raise 'no such object:' + pi[:object][:name] if !x 

      case m

        when 'return'
          x.inuse -= 1

        when 'dispose'
          x.inuse    -= 1
          x.quantity -= 1

        else
          raise 'unknown method in release'

      end

      x.save 

    end
  
  end

  # TERMINAL ########################################################################################

  def render scope
 
    @pi = scope.evaluate @expr
    # TODO: check that @pi is a pdl_item

    if !@pi.kind_of?(Array)
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
        print "Press [ENTER] when finished: "

      when 'dispose'
        puts "Please dispose of the #{length} #{nm} taken from #{loc}."
        puts "  Details: #{method}"
        print "Press [ENTER] when finished: "

      when 'query'
        puts "Please specify whether the #{length} #{nm} taken from #{loc} will be (1) returned or (2) disposed of."
        puts "  Details: #{method}\n\n"
        print "Enter (1) if you returned it or (2) if you disposed of it: "

    end
    
  end

  def execute scope

    input = gets

    if !@pi.kind_of?(Array)
        release_method = @pi.object[:release_method]
        length = 1
    else
        release_method = @pi[0].object[:release_method]
        length = @pi.length
    end

    if release_method == 'query'
      if input.to_i == 1
        method = 'return'
      else
        method = 'dispose'
      end
    else
      method = release_method
    end

    if !@pi.kind_of?(Array) 
      liaison 'release', { id: @pi.item[:id], method: method, quantity: 1 } 
    else
      count = 0
      while count < length
	liaison 'release', { id: @pi[count].item[:id], method: method, quantity: 1 }
	count = count + 1
      end
      
    end

  end

end
