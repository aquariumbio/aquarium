module Krill

  class TaskValidator

    attr_accessor :name

    def initialize task

      @task = task
      @errors = []
      
      path = @task.task_prototype.validator

      if path

        begin
          @name = path.split('/').last.split('.').first.to_sym
          sha = Repo::version path
          code = Repo::contents path, sha
        rescue Exception => e
          @name = :validator_not_found
          @errors.push "Could not find validator at #{path} for task #{@task.name} because #{e.to_s}."          
          @checker = nil
          return # there is no valid validator path
        end

        begin
          # Create Namespace
          namespace = Krill::make_namespace code

          # Add base_class ancestor to user's code
          base_class = make_base
          insert_base_class namespace, base_class

          # Make a base object
          base_object = Class.new.extend(base_class)

          # Make protocol
          @checker = namespace::Validator.new

        rescue Exception => e
          @errors.push "Error while parsing #{path}"
          @errors.push e.to_s
          return
        end

      else

        @name = :validator_not_specified
        @checker = nil

      end

    end

    def check
      if @errors.length > 0
        return @errors
      else
        return ! @checker || @checker.check(@task)
      end
    end

    def make_base

      b = Module.new
      b.send(:include,Base)
      b

    end

    def insert_base_class obj, mod

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          eigenclass = class << self
            self
          end
          eigenclass.send(:include,mod) unless eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          k.send(:include,mod) unless k.include? mod
          insert_base_class k, mod
        end

      end

    end

  end

end