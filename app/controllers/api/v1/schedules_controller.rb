class Api::V1::SchedulesController < ApplicationController
  before_action :authenticate_user

  def index
    render json: Schedule.filter_by_post(params[:eventpost_id]).select(:id, :user_id, :eventpost_id)
  end

  def create
    current_user.schedules.create(eventpost_id: params[:eventpost_id])
    head :created
  end

  def destroy
    schedule = Schedule.find_by(eventpost_id: params[:eventpost_id], user_id: current_user.id)
    schedule.destroy!
    head :ok
  end

  def show
    schedules = Schedule.where(user_id: current_user.id)
    render json: schedules.as_json(include: [{ user: { only: %i[id name user_name] } },
                                             { eventpost: { only: %i[id event_name event_date],
                                                            methods: 'delete_expired_eventpost' } }])
  end
end
