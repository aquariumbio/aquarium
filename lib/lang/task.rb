module Lang

  class Scope 

    def tasks prototype, status

      tp = TaskPrototype.find_by_name(prototype)

      if tp
        Task.where("task_prototype_id = ? AND status = ?", tp.id, status).collect do |t| 
          result = t.attributes.symbolize_keys
          result[:specification] = JSON.parse(result[:specification], symbolize_names: true)
          result
        end
      else
        []
      end

    end

  end

end
