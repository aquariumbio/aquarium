require 'rails_helper'

RSpec.describe Krill do

  def rand_op_spec

    primers = SampleType.find_by_name("Primer").samples
    plasmids = SampleType.find_by_name("Plasmid").samples
    frags = SampleType.find_by_name("Fragment").samples

    pcr = Operation.find_by_name("PCR")
    spec = pcr.parse_spec

    fwd = (spec[:inputs].find { |i| i[:name] == "fwd" })
    rev = (spec[:inputs].find { |i| i[:name] == "rev" })
    tem = (spec[:inputs].find { |i| i[:name] == "template" })
    fra = (spec[:outputs].find { |i| i[:name] == "fragment" })
    ant = (spec[:parameters].find { |i| i[:name] == "annealing_temperature" })
    tc  = (spec[:data].find { |i| i[:name] == "tc" })    

    fwd[:instantiation] = (1..3).collect { |j| { sample: primers[rand(primers.length)].id } }
    rev[:instantiation] = (1..3).collect { |j| { sample: primers[rand(primers.length)].id } }    
    tem[:instantiation] = (1..3).collect { |j| { sample: plasmids[rand(plasmids.length)].id } }
    fra[:instantiation] = (1..3).collect { |j| { sample: frags[rand(frags.length)].id } }
    ant[:instantiation] = (1..3).collect { |k| { value: 70 + 0.1*k } }    
    tc[:instantiation]  = (1..3).collect { |k| {} }        

    spec

  end

  context "workflow interface" do
    it "makes a random spec" do
      o = Krill::Op.new rand_op_spec
      puts "#{o.name}"
      o.input.fwd.take
      o.input.rev.template.take
      o.input.all.release
      o.output.fragment.produce
      o.data.tc[0] = 1
      o.data.tc = [ 1, 2, 3 ]
      puts o.parameter.annealing_temperature[0]
    end
  end

end
