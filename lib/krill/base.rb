module Krill

#  class Manager

    module Namespace
  
      def needs path

        p = "#{path}.rb"
        s = Repo::version p
        content = Repo::contents p, s
        eval(content)

      end

    end

#  end

  def self.get_arguments code

    namespace = Class.new
    namespace.extend(Namespace)
    namespace.class_eval code
    p = namespace::Protocol.new

    if p.respond_to? "arguments"
      p.arguments
    else
      {}
    end

  end

  module Base

    def jid
      nil # To be provided by child class
    end

    def mutex
      nil
    end

    def thread_status
      nil
    end

    def show *page

      puts "#{jid}: STARTING SHOW"

      append_step( { operation: "display", content: page } )

      job = Job.find(jid)
      job.pc += 1
      job.save

      mutex().synchronize { thread_status().running = false }
      puts "#{jid}: PAUSING SHOW FOR THREAD #{Thread.current}"
      Thread.stop
      puts "#{jid}: RESUMING SHOW"

      job.reload
      puts "#{jid}: COMPLETING SHOW"

      JSON.parse(job.state, symbolize_names: true).last[:inputs]

    end

    def error e
      append_step( { operation: "error", message: e.to_s, backtrace: e.backtrace[0,10] } )
      job = Job.find(jid)
      job.reload
      job.save
    end

    private

    def append_step s

      job = Job.find(jid)
      state = JSON.parse job.state, symbolize_names: true
      state.push s
      job.state = state.to_json
      job.save

    end

  end

end
