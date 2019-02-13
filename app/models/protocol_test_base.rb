class ProtocolTestBase

    include MiniTest::Assertions

    attr_accessor :assertions, :logs, :backtrace, :error, :job

    def initialize operation_type, current_user
        @assertions = 0
        @operation_type = operation_type
        @current_user = current_user
        @error = nil
        @job = nil
    end

    def log msg
        @logs ||= []
        @logs << msg
    end

    def add_random_operations num
        @operations = @operation_type.random(num)        
    end

    def add_operation
        op = @operation_type
            .operations
            .create status: 'pending', user_id: @current_user.id
        @operations ||= []
        @operations << op
        op
    end    

    def build_plan
        plans = []
        @operations.each do |op|
            plan = Plan.new user_id: @current_user.id, budget_id: Budget.all.first.id
            plan.save
            plans << plan
            pa = PlanAssociation.new operation_id: op.id, plan_id: plan.id
            pa.save
        end        
    end

    def make_job
        @job, newops = @operation_type.schedule( # newops is not used here
            @operations, 
            @current_user, 
            Group.find_by_name('technicians')
        )     
    end

    def execute
        begin
            manager = Krill::Manager.new @job.id, true, 'master', 'master'
            @operations.extend(Krill::OperationList)
            @operations.make(role: 'input')
            @operations.each(&:run)
            manager.run
            @operations.each(&:reload)
        rescue Exception => e
            @error = e.to_s
        end        
    end

    def run

        build_plan
        make_job
        execute
        @backtrace = @job.reload.backtrace 

    end

end