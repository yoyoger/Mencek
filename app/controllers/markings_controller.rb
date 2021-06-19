class MarkingsController < ApplicationController
  def create
    @micropost = Micropost.find(params[:micropost_id])
    @type = params[:type]
    if @type == 'WantEat'
      current_user.want_eat(@micropost)
    elsif @type == 'Recommend'
      current_user.recommend(@micropost)
    end
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.js { render "markings/#{@type.downcase}" }
    end
  end

  def destroy
    @micropost = Micropost.find(params[:micropost_id])
    @type = current_user.markings.find_by(micropost_id: @micropost.id).type
    if @type == 'WantEat'
      current_user.unwant_eat(@micropost)
    elsif @type == 'Recommend'
      current_user.unrecommend(@micropost)
    end
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.js { render "markings/un#{@type.downcase}" }
    end
  end
end
