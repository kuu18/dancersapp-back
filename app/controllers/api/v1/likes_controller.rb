class Api::V1::LikesController < ApplicationController
  before_action :authenticate_user

  def index
    render json: Like.filter_by_post(params[:eventpost_id]).select(:id, :user_id, :eventpost_id)
  end

  def create
    current_user.likes.create(eventpost_id: params[:eventpost_id])
    head :created
  end

  def destroy
    like = Like.find_by(eventpost_id: params[:eventpost_id], user_id: current_user.id)
    like.destroy!
    head :ok
  end
end
