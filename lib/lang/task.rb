module Lang

  class Scope

    def tasks prototype, status

      tp = TaskPrototype.find_by_name(prototype)
      result = []

      if tp
        result = Task.where("task_prototype_id = ? AND status = ?", tp.id, status).collect do |t|
          result = t.attributes.symbolize_keys
          result[:specification] = JSON.parse(result[:specification], symbolize_names: true)
          result
        end
      end

      result

    end

    def get_task_status task

      t = Task.find_by_id(task[:id])

      if t
        t.status
      else
        "UNKNOWN TASK"
      end

    end

    def set_task_status a, status

      if a.class != Array
        tasks = [a]
      else
        tasks = a
      end

      tasks.each do |task|

        t = Task.find_by_id(task[:id])

        if t

          t.status = status
          t.save

          if $CURRENT_JOB_ID >= 0

            touch = Touch.new
            touch.job_id = $CURRENT_JOB_ID
            touch.task_id = t.id
            touch.save

          end

        end

      end

    end

  end

end
