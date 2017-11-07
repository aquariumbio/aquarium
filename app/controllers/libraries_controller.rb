class LibrariesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def code

    if params[:no_edit]

      render json: {}

    else

      lib = Library.find(params[:id])
      c = lib.code(params[:name])
      
      unless params[:no_edit]
        if c
          c = c.commit(params[:content],current_user)
        else
          c = lib.new_code(params[:name], params[:content],current_user)
        end
      end

      render json: c

    end

  end

  def create

    redirect_to root_path, notice: "Administrative privileges required to access library code." unless current_user.is_admin    

    lib = Library.new name: params[:name], category: params[:category]
    lib.save
    lib.new_code("source", params[:source][:content],current_user)

    render json: lib

  end

  def destroy

   redirect_to root_path, notice: "Administrative privileges required to access library code." unless current_user.is_admin    

   lib = Library.find(params[:id])
   lib.destroy
   render json: { result: "ok" }

   # TODO: Also destroy code? Or leave it there in case someone wants an admin to find it for them?

  end


  def update

    redirect_to root_path, notice: "Administrative privileges required to access library code" unless current_user.is_admin

    lib = Library.find(params[:id])
    
    if lib.update_attributes({ name: params[:name], category: params[:category] })
      render json: lib
    else
      render json: { errors: lib.update_errors }     
    end
  end  

end