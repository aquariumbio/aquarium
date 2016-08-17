namespace :workflow do

  desc 'Setup Workflow'

  task :unseed => :environment do

    ObjectType.find_by_name("Lyophilized Primer").destroy
    ObjectType.find_by_name("Checked E coli Plate of Plasmid").destroy    
    OperationType.destroy_all
    Operation.destroy_all
    Code.destroy_all

  end

  task :seed => :environment do 

    lp = ObjectType.new(name: "Lyophilized Primer", handler: "sample_container", unit: "tube", min: 1, max: 10000,
                        release_method: "return", description: "Some barely visible white powder", cost: 5.00)
    lp.save

    # raise "Could not make object type: #{lp.errors.full_messages.join(', ')}" unless lp.errors.empty?

    cp = ObjectType.new(name: "Checked E coli Plate of Plasmid", handler: "sample_container", unit: "plate", min: 1, max: 10000,
                        release_method: "return", description: "A plate that actually has some colonies on it", cost: 5.00)
    cp.save

    # raise "Could not make object type: #{lp.errors.full_messages.join(', ')}" unless lp.errors.empty?  

    op = OperationType.new name: "Order Primer"
    op.save
    op.add_output( "Primer", "Primer", "Lyophilized Primer" )  

    rp = OperationType.new name: "Receive Primer"
    rp.save
    rp.add_input(  "Primer", "Primer", "Lyophilized Primer" )
      .add_output( "Primer", "Primer", "Primer Stock" )
      .add_output( "Primer", "Primer", "Primer Aliquot" )

    mpa = OperationType.new name: "Make Primer Aliquot"
    mpa.save
    mpa.add_input( "Primer", "Primer",   "Primer Stock")
      .add_output( "Primer", "Primer",   "Primer Aliquot")
    
    pcr = OperationType.new name: "PCR"
    pcr.save
    pcr.add_input(  "Forward Primer", "Primer",   "Primer Aliquot" )
       .add_input(  "Reverse Primer", "Primer",   "Primer Aliquot" )
       .add_input(  "Template",       [ "Plasmid", "Fragment" ],  [ "Plasmid Stock", "Fragment Stock" ] )
       .add_output( "Fragment",       "Fragment", "Stripwell", part: true ) 

    run_gel = OperationType.new name: "Run Gel"
    run_gel.save
    run_gel.add_input(  "Fragment", "Fragment",  "Stripwell", part: true )
           .add_output( "Fragment", "Fragment",  "50 mL 0.8 Percent Agarose Gel in Gel Box", part: true )

    extract_fragment = OperationType.new name: "Extract Fragment"
    extract_fragment.save
    extract_fragment.add_input(  "Fragment", "Fragment",  "50 mL 0.8 Percent Agarose Gel in Gel Box", part: true )
                    .add_output( "Fragment", "Fragment",  "Gel Slice" )

    purify_gel = OperationType.new name: "Purify Gel"
    purify_gel.save
    purify_gel.add_input(  "Fragment", "Fragment",   "Gel Slice" )
              .add_output( "Fragment", "Fragment",  "Fragment Stock" )

    gibson = OperationType.new name: "Gibson Assembly"
    gibson.save
    gibson.add_input(  "Fragment", "Fragment", "Fragment Stock", array: true )
          .add_output( "Assembled Plasmid", "Plasmid",  "Gibson Reaction Result" )

    transform = OperationType.new name: "Transform E coli"
    transform.save
    transform.add_input(  "Plasmid", "Plasmid",  "Gibson Reaction Result" )
             .add_input(  "Comp cell", "E coli strain", "Electrocompetent aliquot" )      
             .add_output( "Plasmid", "Plasmid", "Transformed E coli 1.5 mL tube" ) 

    plate = OperationType.new name: "Plate E coli"
    plate.save
    plate.add_input(  "Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" ) # can I add a few other possible object types here (see pcr)?
         .add_output( "Plasmid", "Plasmid",  "E coli Plate of Plasmid" )

    check_plate = OperationType.new name: "Check E coli Plate"
    check_plate.save
    check_plate.add_input(  "Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" ) 
               .add_output( "Plasmid", "Plasmid",  "Checked E coli Plate of Plasmid" )

    overnight = OperationType.new name: "E coli Overnight"
    overnight.save
    overnight.add_input(  "Plasmid", "Plasmid",  "Checked E coli Plate of Plasmid" )
             .add_output( "Plasmid", "Plasmid",  "TB Overnight of Plasmid" )  

    mp = OperationType.new name: "Miniprep"
    mp.save
    mp.add_input( "Plasmid", "Plasmid", "TB Overnight of Plasmid")
      .add_output( "Plasmid", "Plasmid", "Plasmid Stock")

    seq = OperationType.new name: "Sequencing"
    seq.save
    seq.add_input( "Plasmid", "Plasmid", "Plasmid Stock")

    puts       "---------------"
    puts "\e[93mSeeded Operation Types\e[39m"
    puts OperationType.all.collect { |ot| "  " + ot.name }

    protocol = File.open("lib/tasks/default.rb", "r").read
    OperationType.all.each do |ot|
      ot.new_code("protocol", "# #{ot.name} Protocol\n\n" + protocol)
      ot.new_code "cost_model", "# #{ot.name} Cost Model\n\ndef cost(ot)\n  { labor: 0, materials: 0 }\nend"
      ot.new_code "documentation", "#{ot.name}\n===\n\nDocumentation here"
    end

  end

end
