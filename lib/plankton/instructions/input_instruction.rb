# frozen_string_literal: true

module Plankton

  class InputInstruction < Instruction

    def initialize(repo, v, filename_expr, options = {})
      @repo = repo
      @var = v
      @filename_expr = filename_expr
      @renderable = false
      super 'input', options
    end

    def bt_execute(scope, params)

      path = scope.evaluate @filename_expr

      repo_path = if /:/ =~ path
                    path.split(/:/).join('/')
                  else
                    @repo + '/' + path
                  end

      sha = Repo.version repo_path
      data = Repo.contents repo_path, sha

      j = JSON.parse(data, symbolize_names: true)
      scope.set @var.to_sym, j

      log = Log.new
      log.job_id = params[:job]
      log.user_id = scope.stack.first[:user_id]
      log.entry_type = 'INPUT'
      log.data = { var: @var, filename: path, sha: sha }.to_json
      log.save

    end

  end

end
