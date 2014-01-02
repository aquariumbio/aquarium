dups = []

ObjectType.all.each do |a|
  ObjectType.all.each do |b|
    if a.id != b.id && a.name == b.name
      dups.push [ a.id, a.name ]
    end
  end
end

puts dups.to_s
