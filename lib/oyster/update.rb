while true

  sleep 1

  Metacol.where("status = 'RUNNING'").each do |process|

    blob = Blob.get process.sha, process.path
    content = blob.xml

    m = Oyster::Parser.new(content).parse
    m.set_state( JSON.parse process.state, :symbolize_names => true )

    m.update

    process.state = m.state.to_json

    if m.done?
      process.status = "DONE"
    end

    process.save

  end

end
