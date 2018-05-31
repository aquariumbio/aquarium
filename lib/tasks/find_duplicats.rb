

dups = []

ObjectType.all.each do |a|
  ObjectType.all.each do |b|
    dups.push [a.id, a.name] if a.id != b.id && a.name == b.name
  end
end

puts dups.to_s
