class MarkingsController < ApplicationController
  def create
    @micropost = Micropost.find(params[:micropost_id])
    if params[:type] == 'WantEat'
      current_user.want_eat(@micropost)
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js
      end
    end
  end

  def destroy
    @micropost = Micropost.find(params[:micropost_id])
    if current_user.markings.find_by(micropost_id: @micropost.id).type == 'WantEat'
      current_user.unwant_eat(@micropost)
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js
      end
    end
  end
end
