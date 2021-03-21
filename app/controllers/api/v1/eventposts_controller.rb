class Api::V1::EventpostsController < ApplicationController
  before_action :authenticate_user
  before_action :correct_user, only: :destroy

  def index
    feed_items = current_user.feed
    payload = feed_items.as_json(methods: 'image_url', include: { user: { only: %i[id name user_name email] } })
    render json: payload
  end

  def create
    @eventpost = current_user.eventposts.build(eventpost_params)
    @eventpost.image.attach(params[:image])
    payload = if @eventpost.save
                {
                  type: 'success',
                  msg: 'イベントを作成しました'
                }
              else
                {
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
    params.permit(:content, :event_name, :event_date, :image)
  end

  def correct_user
    @eventpost = current_user.eventposts.find_by(id: params[:id])
    head(:not_found) if @eventpost.nil?
  end
end
