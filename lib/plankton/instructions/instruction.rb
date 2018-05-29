# frozen_string_literal: true

module Plankton

  class Instruction

    attr_reader :name, :renderable, :flash, :console_messages, :startline, :endline
    attr_writer :pc

    def initialize(name, options = {})
      @name = name
      @flash = ''
      @console_messages = []
      @startline = options[:startline]
      @endline = options[:endline]
    end

    def adjust_offset(o)
      @pc += o
    end

    def clear
      puts "\e[2J\e[f"
    end

    def liaison(verb, args)
      uri = URI("http://bioturk.ee.washington.edu:3010/liaison/#{verb}.json")
      uri.query = URI.encode_www_form(args)
      result = Net::HTTP.get_response(uri)
      JSON.parse(result.body, symbolize_names: true)
    end

    def to_s
      @name + "\n  " + (instance_variables.map { |i| "#{i}: " + (instance_variable_get i).to_s }).join("\n  ")
    end

    def html
      h = "<b>#{@name}</b><ul class='list'>"
      instance_variables.each do |i|
        h += "<li>#{i}: #{instance_variable_get i}</li>"
      end
      h += '</ul>'
      h
    end

    def do_not_render
      @renderable = false
    end

    def console(msg)
      @console_messages.push msg
    end

    def pdl_item(item)
      if item.class != Item
        raise 'Could not convert argument to PDL item, because it was not a Rails Item to start with.'
      else
        d = item.data ? item.data : '{ "error": "Could not parse json data" }'
        begin
          data = JSON.parse(d.gsub(/\b0*(\d+)/, '\1'), symbolize_names: true)
        rescue Exception => e
          data = {}
        end
        { id: item.id, name: item.object_type.name, data: data, location: item.location }
      end
    end

  end

end
