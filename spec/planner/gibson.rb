def plan_gibson n

  gibson = OperationType.find_by_name "Gibson Assembly"

  gop = gibson.operations.create status: "planning", user_id: User.find_by_login("klavins").id
  
  frags = SampleType.find_by_name("Fragment").samples

  gop.set_output("Assembled Plasmid", SampleType.find_by_name("Plasmid").samples.last)
     .set_input("Fragments", frags.sample(n))
     .set_input("Comp cell", Sample.find_by_name("DH5alpha"))

  puts
  puts "\e[93mPlanning #{gop}\e[39m"

  planner = Planner.new OperationType.all
  planner.plan_tree gop

  puts
  puts "\e[93mMarking shortest plan\e[39m"
  planner.mark_shortest gop

  puts
  puts "\e[93mMarking unused operations\e[39m"  
  planner.mark_unused gop

  gop.reload
  gop

end