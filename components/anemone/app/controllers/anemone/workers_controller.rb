# typed: true
module Anemone

  class WorkersController < ApplicationController

    def show

      begin
        worker = Worker.find(params[:id])
        render json: worker
      rescue Exception => e
        render json: { error: e.to_s }
      end

    end

  end

end
