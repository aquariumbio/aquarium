require "rails_helper"

RSpec.describe "Planner" do

  context "gibson" do

    it "works" do

      puts "- Creating Required Object Types"

      lp = ObjectType.new(name: "Lyophilized Primer", handler: "sample_container", unit: "tube", min: 1, max: 10000,
                          release_method: "return", description: "Some barely visible white powder", cost: 5.00)
      lp.save

      raise "Could not make object type: #{lp.errors.full_messages.join(', ')}" unless lp.errors.empty?

      puts "- Building Operation Types"

      gibson = OperationType.new name: "Gibson Assembly"
      gibson.save
      gibson.add_input(  "Fragments", "Fragment", "Stripwell", array: true )
            .add_input(  "Comp cell", "E coli strain", "Electrocompetent aliquot", array: true )      
            .add_output(  "Assembled Plasmid", "Plasmid",  "Transformed E coli 1.5 mL tube" )

      fe = OperationType.new name: "Fragment Extraction"
      fe.save
      fe.add_input(  "Fragment", "Fragment",   "Stripwell", array: true )
        .add_output(  "Fragment", "Fragment",  "Fragment Stock" )

      pcr = OperationType.new name: "PCR"
      pcr.save
      pcr.add_input(  "Forward Primer", "Primer",   "Primer Aliquot" )
         .add_input(  "Reverse Primer", "Primer",   "Primer Aliquot" )
         .add_input(  "Template",       [ "Plasmid", "Fragment" ],  [ "Plasmid Stock", "Fragment Stock" ] )
         .add_output( "Fragment",       "Fragment", "Stripwell" )

      pa = OperationType.new name: "PrimerAliquot"
      pa.save
      pa.add_input(  "Primer", "Primer",   "Primer Stock")
        .add_output( "Primer", "Primer",   "Primer Aliquot")

      rp = OperationType.new name: "ReceivePrimer"
      rp.save
      rp.add_input(  "Primer", "Primer", "Lyophilized Primer" )
        .add_output( "Primer", "Primer", "Primer Stock" )
        .add_output( "Primer", "Primer", "Primer Aliquot" )

      op = OperationType.new name: "OrderPrimer"
      op.save
      op.add_output( "Primer", "Primer", "Lyophilized Primer" )  

      puts OperationType.all.collect { |ot| "    - " + ot.name }

      puts "- Instantiating Output Operation (Gibson Assembly)"

      gop = gibson.operations.create status: "planning"
      gop.set_output("Assembled Plasmid", SampleType.find_by_name("Plasmid").samples.last)
         .set_input("Fragments", SampleType.find_by_name("Fragment").samples.sample(5))

      puts "gop.inputes = #{gop.inputs}"

      planner = Planner.new OperationType.all
      planner.plan gop

    end

  end

end
