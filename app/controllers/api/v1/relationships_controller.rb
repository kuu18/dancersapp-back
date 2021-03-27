class Api::V1::RelationshipsController < ApplicationController
  before_action :authenticate_user

  def create
    user = User.find_by(user_name: params[:user_name])
    current_user.follow(user)
    render json: current_user.following?(user)
  end

  def destroy
    user = User.find_by(user_name: params[:user_name])
    current_user.unfollow(user)
    render json: current_user.following?(user)
  end
end
