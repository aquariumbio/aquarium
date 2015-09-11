require 'socket'              

module Krill

  class Client

    def initialize

      @hostname = 'localhost'
      
      if Rails.env == 'production'
        @port = 3501
      else
        @port = 3500
      end

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

    def start jid, debug=false
      send operation: "start", jid: jid, debug: debug
    end

    def jobs
      send operation: "jobs"
    end

    def abort jid
      send operation: "abort", jid: jid
    end

    def continue jid
      send operation: "continue", jid: jid
    end

    def kill_zombies
      send operation: "kill zombies" 
    end

  end

end
