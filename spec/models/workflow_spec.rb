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
      {name: "fwd",      sample: fwd.id }, 
      {name: "rev",      sample: rev.id }, 
      {name: "template", sample: template.id },
      {name: "fragment", sample: frag.id },     
      {name: "annealing_temperature", value: 71.3}
    ]

  end

  def make_process wid, n

    w = Workflow.find(wid)

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

      p = make_process 11, 3
      
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
      puts "#{((Time.now-t1).seconds*1000).to_i}: Making process"

      p = make_process 11, 5
      puts "Made process #{p.id}"
      p.launch
      
      puts "#{((Time.now-t1).seconds*1000).to_i}: Running process #{p.id}"

      jobs = Job.last(2)

      s1 = Krill::Client.new.start jobs[0].id
      s2 = Krill::Client.new.start jobs[1].id

      puts "#{((Time.now-t1).seconds*1000).to_i}: Done"

      jobs[0].reload
      jobs[1].reload

      p.record_result_of jobs[0]
      p.record_result_of jobs[1]

      unless p.errors.empty?
        raise "Could not record results of jobs."
      end 

      puts "#{jobs[0].id}: #{jobs[0].status}, #{jobs[1].id}: #{jobs[1].status}\n\n"
      puts "#{jobs[0].backtrace.select { |o| o[:operation] == "error" }}\n\n"
      puts "#{jobs[1].backtrace.select { |o| o[:operation] == "error" }}"

      exec "open http://localhost:3000/workflow_processes/#{p.id}"

    end

    it "runs a workflow" do

      # make a process with workflow number 11 (fragment construction) and five threads
      p = make_process 11, 5
      puts "make process #{p.id}"

      # launch the workflow, putting the initial jobs on the queue
      # and the job id in the associated operation container (oc)
      p.launch

      i = 0 # avoid infinite loops during development

      while !p.completed? && i < 10

        # run all jobs associated with the workflow
        puts "Workflow jobs: #{p.jobs.collect{|j|j.id}}"
        (p.jobs.select { |job| job.not_started? }).each do |job|
          puts "starting job #{job.id}"
          result = Krill::Client.new.start job.id
          puts result
          if result[:response] == "error"
            raise "Krill could not start #{job.id}: #{result[:error]}"
          end
          job.reload
          if job.error?
            puts "Job #{job.id} failed: #{job.error_message}"
            puts job.error_backtrace.join("\n")            
            raise "Job #{job.id} failed"
          end
          p.record_result_of job
        end

        # step the workflow so that new jobs are queued up based on the
        # results of completed jobs
        p.step

        # reload the workflow to get jobs list for next iteration
        p.reload

        i += 1

      end

      exec "open http://localhost:3000/workflow_processes/#{p.id}"      

    end

  end

end
