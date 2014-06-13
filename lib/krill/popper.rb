require 'socket'      # Sockets are in standard library
require 'JSON'

hostname = 'localhost'
port = 3500

s = TCPSocket.open(hostname, port)
msg = { operation: "recv", queue: ARGV[0] }.to_json
s.puts msg

while line = s.gets   # Read lines from the socket
  puts line.chop      # And print with platform line terminator
end

s.close               # Close the socket when done
