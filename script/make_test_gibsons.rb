tp = TaskPrototype.where("name = 'Gibson Assembly'")[0]
plasmids = SampleType.where("name = 'Plasmid'")[0].samples
frags = SampleType.where("name = 'Fragment'")[0].samples
primers = SampleType.where("name = 'Primer'")[0].samples
users = User.all

(1..25).each do |i|

  t = Task.new
  t.name = "Gibson#{i+10}"
  t.specification = ({
    "target Plasmid" => plasmids.sample.id,
    "fragments Fragment" => frags.sample(3).collect { |f| f.id },
    "sequencing_primers Primer" => primers.sample(2).collect { |p| p.id }
  }).to_json
  t.task_prototype_id = tp.id
  t.status = "waiting for fragments"
  t.user_id = users.sample.id

  puts t.attributes.to_s

  t.save
  puts t.id

end