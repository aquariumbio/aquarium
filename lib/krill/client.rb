require 'socket'              

module Krill

  class Client

    def initialize

      @hostname = 'localhost'
      @port = 3500

    end

    def open
      begin      
        @socket = TCPSocket.open(@hostname, @port)
      rescue
        raise "Could not connect to Krill server. It is probably not running."
      end
    end

    def close
      @socket.close
    end

    def send x

      open

      msg = x.to_json
      @socket.puts msg

      answer = ""
      while line = @socket.gets 
        answer += line.chop 
      end

      close

      JSON.parse answer, symbolize_names: true

    end

    def start jid
      send( { operation: "start", jid: jid } )
    end

    def continue jid
      send( { operation: "continue", jid: jid } )
      # (JSON.parse Job.find(jid).state, symbolize_names: true)[:content]
    end

    def kill_zombies
      send( { operation: "kill zombies" } )
    end

  end

end
