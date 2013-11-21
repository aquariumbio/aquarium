while true

  sleep 1

  Metacol.where("status = 'RUNNING'").each do |process|

    blob = Blob.get process.sha, process.path
    content = blob.xml

    error = false
    begin
      m = Oyster::Parser.new(content).parse
    rescue Exception => e
      error = true
      puts "Warning: " + e
    end

    if !error

      m.set_state( JSON.parse process.state, :symbolize_names => true )
      m.id = process.id

      m.update

      process.state = m.state.to_json

      if m.done?
        process.status = "DONE"
      end

      process.save

    else

      process.status = "ERROR"
      process.save

    end

  end

end
