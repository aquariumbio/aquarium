generic = 'lambda { |spec| { materials: 0, labor: 0 } }'

TaskPrototype.all.each do |tp|

  puts "#{tp.name} => { "

  s = JSON.parse(tp.status_options).collect do |so|
    "  #{so} => #{generic}"
  end

  puts s.join(",\n")

  puts '}, '

end
