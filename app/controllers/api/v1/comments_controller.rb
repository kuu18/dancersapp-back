class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user
  def create
    comment = current_user.comments.new(comment_params)
    render json: { type: 'success', msg: 'コメントしました' } if comment.save
  end

  def destroy
    comment = Comment.find(params[:comment_id])
    comment.destroy!
    head :ok
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :eventpost_id)
  end
end
