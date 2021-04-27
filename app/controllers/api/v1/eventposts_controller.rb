class Api::V1::EventpostsController < ApplicationController
  before_action :authenticate_user
  before_action :correct_user, only: :destroy

  def index
    feed_items = current_user.feed.page(params[:page]).per(5)
    pagenation = resources_with_pagination(feed_items)
    @feed_items = feed_items.as_json(methods: %w[image_url delete_expired_eventpost],
                                     include: [{ user: { only: %i[id name user_name email], methods: 'avatar_url' } },
                                               { comments: { only: %i[id] } }])
    payload = { feed_items: @feed_items, kaminari: pagenation }
    render json: payload
  end

  def show
    eventpost = Eventpost.find(params[:eventpost_id]).eventpost_json
    render json: eventpost
  end

  def user_eventposts
    user = User.find_by(user_name: params[:user_name])
    eventposts = if user
                   user.eventposts.page(params[:page]).per(12)
                 else
                   current_user.eventposts.page(params[:page]).per(12)
                 end
    @eventposts = eventposts.as_json(methods: 'image_url', include: { user: { only: %i[id name user_name email] } })
    pagenation = resources_with_pagination(eventposts)
    payload = { eventposts: @eventposts, kaminari: pagenation }
    render json: payload
  end

  def create
    @eventpost = current_user.eventposts.build(eventpost_params)
    @eventpost.image.attach(params[:image])
    payload = if @eventpost.save
                current_user.schedules.create(eventpost_id: @eventpost.id)
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

  def search
    q = Eventpost.ransack(search_params)
    @eventposts = q.result(distinct: true).page(params[:page]).per(10)
    pagenation = resources_with_pagination(@eventposts)
    payload = {
      eventposts: @eventposts.as_json(only: %i[id event_name event_date],
                                      include: { user: { only: %i[name], methods: 'avatar_url' } }),
      kaminari: pagenation
    }
    render json: payload
  end

  private

  def eventpost_params
    params.permit(:content, :event_name, :event_date, :image)
  end

  def search_params
    params.permit(:event_name_cont, :event_date_gteq, :event_date_lteq_end_of_day, :page)
  end

  def correct_user
    @eventpost = current_user.eventposts.find_by(id: params[:id])
    head(:not_found) if @eventpost.nil?
  end

  def resources_with_pagination(resources)
    {
      pagenation: {
        current: resources.current_page,
        previous: resources.prev_page,
        next: resources.next_page,
        limit_value: resources.limit_value,
        pages: resources.total_pages,
        count: resources.total_count
      }
    }
  end
end
