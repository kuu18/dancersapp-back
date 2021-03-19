class Api::V1::EventpostsController < ApplicationController
  before_action :authenticate_user
  before_action :correct_user,   only: :destroy

  def index
    feed_items = current_user.feed
    payload = feed_items.as_json(include: {user: { only:[:id, :name, :user_name, :email] } })
    render json: payload
  end

  def create
    @eventpost = current_user.eventposts.build(eventpost_params)
    if @eventpost.save
      payload = {
        type: 'success',
        msg: 'イベントを作成しました'
      }
    else
      payload = {
        type: 'error',
        errors: @eventpost.errors.full_messages
      }
    end
    render json: payload
  end

  def destroy
    @eventpost.destroy
    payload = {
      msg: '投稿を削除しました',
      type: 'success'
    }
    render json: payload
  end

  private
    def eventpost_params
      params.require(:eventpost).permit(:content, :event_name, :event_date)
    end

    def correct_user
      @eventpost = current_user.eventposts.find_by(id: params[:id])
      head(:not_found) if @eventpost.nil?
    end
end
