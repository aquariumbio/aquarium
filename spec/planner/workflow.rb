def build_workflow

  lp = ObjectType.new(name: "Lyophilized Primer", handler: "sample_container", unit: "tube", min: 1, max: 10000,
                      release_method: "return", description: "Some barely visible white powder", cost: 5.00)
  lp.save

  raise "Could not make object type: #{lp.errors.full_messages.join(', ')}" unless lp.errors.empty?

  op = OperationType.new name: "Order Primer", protocol: "protocols/planner/order_primer.rb"
  op.save
  op.add_output( "Primer", "Primer", "Lyophilized Primer" )  

  rp = OperationType.new name: "Receive Primer", protocol: "protocols/planner/receive_primer.rb"
  rp.save
  rp.add_input(  "Primer", "Primer", "Lyophilized Primer" )
    .add_output( "Primer", "Primer", "Primer Stock" )
    .add_output( "Primer", "Primer", "Primer Aliquot" )

  mpa = OperationType.new name: "Make Primer Aliquot", protocol: "protocols/planner/make_primer_aliquot.rb"
  mpa.save
  mpa.add_input(  "Primer", "Primer",   "Primer Stock")
    .add_output( "Primer", "Primer",   "Primer Aliquot")
  
  pcr = OperationType.new name: "PCR", protocol: "protocols/planner/pcr.rb"
  pcr.save
  pcr.add_input(  "Forward Primer", "Primer",   "Primer Aliquot" )
     .add_input(  "Reverse Primer", "Primer",   "Primer Aliquot" )
     .add_input(  "Template",       [ "Plasmid", "Fragment" ],  [ "Plasmid Stock", "Fragment Stock" ] )
     .add_output( "Fragment",       "Fragment", "Stripwell", part: true ) 

  run_gel = OperationType.new name: "Run Gel", protocol: "protocols/planner/run_gel.rb" # aka purify gel
  run_gel.save
  run_gel.add_input(  "Fragment", "Fragment",   "Stripwell", part: true )
         .add_output( "Fragment", "Fragment",  "50 mL 0.8 Percent Agarose Gel in Gel Box", part: true )

  extract_fragment = OperationType.new name: "Extract Fragment", protocol: "protocols/planner/extract_fragment.rb"
  extract_fragment.save
  extract_fragment.add_input(  "Fragment", "Fragment",  "50 mL 0.8 Percent Agarose Gel in Gel Box", part: true )
                  .add_output( "Fragment", "Fragment",  "Gel Slice" )

  purify_gel = OperationType.new name: "Purify Gel", protocol: "protocols/planner/purify_gel.rb" 
  purify_gel.save
  purify_gel.add_input(  "Fragment", "Fragment",   "Gel Slice" )
            .add_output( "Fragment", "Fragment",  "Fragment Stock" )

  gibson = OperationType.new name: "Gibson Assembly", protocol: "protocols/planner/gibson_assembly.rb"
  gibson.save
  gibson.add_input(  "Fragments", "Fragment", "Fragment Stock", array: true )
        .add_output( "Assembled Plasmid", "Plasmid",  "Gibson Reaction Result" )

  transform = OperationType.new name: "Transform E coli", protocol: "protocols/planner/transform_e_coli.rb"
  transform.save
  transform.add_input(  "Plasmid", "Plasmid",  "Gibson Reaction Result" )
           .add_input(  "Comp cell", "E coli strain", "Electrocompetent aliquot" )      
           .add_output( "Plasmid", "Plasmid", "Transformed E coli 1.5 mL tube" ) 

  plate = OperationType.new name: "Plate E coli", protocol: "protocols/planner/plate_e_coli.rb" 
  plate.save
  plate.add_input(  "Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" ) # can I add a few other possible object types here (see pcr)?
       .add_output( "Plasmid", "Plasmid",  "E coli Plate of Plasmid" )

  check_plate = OperationType.new name: "Check E coli Plate", protocol: "protocols/planner/check_e_coli_plate.rb" 
  check_plate.save
  check_plate.add_input(  "Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" ) 
             .add_output( "Plasmid", "Plasmid",  "E coli Plate of Plasmid" )

  overnight = OperationType.new name: "E coli Overnight", protocol: "protocols/planner/e_coli_overnight.rb" 
  overnight.save
  overnight.add_input(  "Plasmid", "Plasmid",  "E coli Plate of Plasmid" )
           .add_output( "Plasmid", "Plasmid",  "TB Overnight of Plasmid" )  

  mp = OperationType.new name: "Miniprep", protocol: "protocols/planner/miniprep.rb"
  mp.save
  mp.add_input( "Plasmid", "Plasmid", "TB Overnight of Plasmid")
    .add_output( "Plasmid", "Plasmid", "Plasmid Stock")

  seq = OperationType.new name: "Sequencing", protocol: "protocols/planner/sequencing.rb"
  seq.save
  seq.add_input( "Plasmid", "Plasmid", "Plasmid Stock")

  puts       "---------------"
  puts "\e[93mOperation Types\e[39m"
  puts OperationType.all.collect { |ot| "    - " + ot.name }

end