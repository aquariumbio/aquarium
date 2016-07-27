def build_workflow

  lp = ObjectType.new(name: "Lyophilized Primer", handler: "sample_container", unit: "tube", min: 1, max: 10000,
                      release_method: "return", description: "Some barely visible white powder", cost: 5.00)
  lp.save

  raise "Could not make object type: #{lp.errors.full_messages.join(', ')}" unless lp.errors.empty?

  gibson = OperationType.new name: "Gibson Assembly", protocol: "protocols/planner/gibson_assembly.rb"
  gibson.save
  gibson.add_input(  "Fragments", "Fragment", "Stripwell", array: true )
        .add_input(  "Comp cell", "E coli strain", "Electrocompetent aliquot" )      
        .add_output(  "Assembled Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" )

  fe = OperationType.new name: "Extract Fragment", protocol: "protocols/planner/extract_fragment.rb"
  fe.save
  fe.add_input(  "Fragment", "Fragment",   "Stripwell" )
    .add_output(  "Fragment", "Fragment",  "Fragment Stock" )

  pcr = OperationType.new name: "PCR", protocol: "protocols/planner/pcr.rb"
  pcr.save
  pcr.add_input(  "Forward Primer", "Primer",   "Primer Aliquot" )
     .add_input(  "Reverse Primer", "Primer",   "Primer Aliquot" )
     .add_input(  "Template",       [ "Plasmid", "Fragment" ],  [ "Plasmid Stock", "Fragment Stock" ] )
     .add_output( "Fragment",       "Fragment", "Stripwell" )

  pa = OperationType.new name: "Make Primer Aliquot", protocol: "protocols/planner/make_primer_aliquot.rb"
  pa.save
  pa.add_input(  "Primer", "Primer",   "Primer Stock")
    .add_output( "Primer", "Primer",   "Primer Aliquot")

  rp = OperationType.new name: "Receive Primer", protocol: "protocols/planner/receive_primer.rb"
  rp.save
  rp.add_input(  "Primer", "Primer", "Lyophilized Primer" )
    .add_output( "Primer", "Primer", "Primer Stock" )
    .add_output( "Primer", "Primer", "Primer Aliquot" )

  op = OperationType.new name: "Order Primer", protocol: "protocols/planner/order_primer.rb"
  op.save
  op.add_output( "Primer", "Primer", "Lyophilized Primer" )  

  puts "\e[93mOperation Types\e[39m"
  puts OperationType.all.collect { |ot| "    - " + ot.name }

end