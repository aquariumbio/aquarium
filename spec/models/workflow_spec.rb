require 'rails_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = false
end

RSpec.describe Workflow, :type => :model do

  context "forms" do
    it "makes forms" do
      Workflow.find(11).form
    end
  end

  def make_random_thread_spec

    primers = SampleType.find_by_name("Primer").samples
    plasmids = SampleType.find_by_name("Plasmid").samples
    frags = SampleType.find_by_name("Fragment").samples

    begin 
      fwd = primers[rand(primers.length)]
    end while fwd.items.length == 0

    begin
      rev = primers[rand(primers.length)]
    end while rev.items.length == 0

    begin
      template = plasmids[rand(plasmids.length)]
    end while template.items.length == 0

    frag = frags[rand(frags.length)]

    [
      {name: "fwd",      sample: fwd.id, container: ObjectType.find_by_name("Primer Aliquot").id }, 
      {name: "rev",      sample: rev.id, container: ObjectType.find_by_name("Primer Aliquot").id }, 
      {name: "template", sample: template.id, container: ObjectType.find_by_name("Plasmid Stock").id },
      {name: "fragment", sample: frag.id },     
      {name: "annealing_temperature", value: 71.3}
    ]

  end

  def make_process n

    w = Workflow.find(11)

    threads = (1..n).collect { |i|
      (w.new_thread make_random_thread_spec).reload
    }

    p = WorkflowProcess.create w, threads
    p.reload

  end

  context "threads" do

    it "makes new threads and associations" do

      num_threads = WorkflowThread.count
      num_associations = WorkflowAssociation.count

      t = Workflow.find(11).new_thread make_random_thread_spec

      expect(num_threads < WorkflowThread.count && num_associations < WorkflowAssociation.count).to eq(true)

    end

  end

  context "process" do

    it "initializes" do

      p = make_process 3
      
      p.all_parts.each do |part|
        if !part[:shared]
          expect(part[:instantiation].length).to eq(3.0)
        end
      end

    end

    it "launches initial protocols" do

      RSpec.configure do |config|
        config.use_transactional_fixtures = false
      end

      t1 = Time.now
      puts "#{((Time.now-t1).seconds*1000).to_i}: Making processes"

      p = make_process 22
      p.launch
      
      puts "#{((Time.now-t1).seconds*1000).to_i}: Running"

      jobs = Job.last(2)

      s1 = Krill::Client.new.start jobs[0].id
      s2 = Krill::Client.new.start jobs[1].id

      puts "#{((Time.now-t1).seconds*1000).to_i}: Done"

      jobs[0].reload
      jobs[1].reload

      puts "#{jobs[0].id}: #{jobs[0].status}, #{jobs[1].id}: #{jobs[1].status}\n\n"
      puts "#{jobs[0].backtrace.select { |o| o[:operation] == "error" }}\n\n"
      puts "#{jobs[1].backtrace.select { |o| o[:operation] == "error" }}"

      p.reload

      RSpec.configure do |config|
        config.use_transactional_fixtures = true
      end

    end

  end

end