class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, except: [:create]

  def index
    user = User.find_by(user_name: params[:user_name])
    render json: { other_user: user.my_json, relationship: current_user.following?(user) }
  end

  def create
    @user = User.new(user_params)
    @user.avatar.attach(io: File.open('spec/fixtures/user/default_image.png'), filename: 'default_image.png',
      content_type: 'image/png')
    if @user.save
      @user.send_email_for(:account_activation)
      payload = {
        type: 'info',
        msg: '認証メールを送信しました。' \
            '２時間以内にメール認証を完了してください'
      }
    else
      payload = {
        type:'error',
        errors: @user.errors.full_messages
      }
    end
    render json: payload
  end

  def show
    render json: current_user.my_json
  end

  def update
    @user = current_user
    payload = if @user.update(user_params)
                {
                  type: 'success',
                  msg: 'プロフィールを変更しました'
                }
              else
                {
                  type: 'error',
                  msg: 'プロフィールの変更に失敗しました'
                }
              end
    render json: payload
  end

  def change_email
    @user = current_user
    if @user.email != user_params[:email] && @user.update(user_params)
      @user.update(activated: false)
      @user.send_email_for(:account_activation)
      payload = {
        type: 'info',
        msg: '認証メールを送信しました。' \
              '２時間以内にメール認証を完了してください'
      }
    else
      payload = {
        type: 'error',
        msg: 'エラーがあります'
      }
    end
    render json: payload
  end

  def change_password
    @user = current_user
    payload = if @user.authenticate(params[:user][:old_password])
                if !@user.authenticate(user_params[:password]) && @user.update(user_params)
                  {
                    type: 'success',
                    msg: 'パスワードを変更しました'
                  }
                else
                  {
                    type: 'error',
                    msg: 'エラーがあります'
                  }
                end
              else
                {
                  type: 'error',
                  msg: '現在のパスワードが違います'
                }
              end
    render json: payload
  end

  def destroy
    @user = current_user
    if @user.authenticate(user_params[:password])
      @user.destroy
      payload = {
        type: 'success',
        msg: 'アカウントを削除しました'
      }
    else
      payload = {
        type: 'error',
        msg: 'パスワードが違います'
      }
    end
    render json: payload
  end

  def following
    user  = User.find_by(user_name: params[:user_name])
    users = user.following.as_json(methods: 'avatar_url', only: %i[id name user_name])
    render json: users
  end

  def followers
    user  = User.find_by(user_name: params[:user_name])
    users = user.followers.as_json(methods: 'avatar_url', only: %i[id name user_name])
    render json: users
  end

  def avatar
    current_user.avatar.attach(params[:avatar])
    payload = {
      type: 'success',
      msg: 'プロフィール画像を変更しました'
    }
    render json: payload
  end

  def avatar_destroy
    current_user.avatar.attach(io: File.open('spec/fixtures/user/default_image.png'), filename: 'initial_image.png',
    content_type: 'image/png')
    payload = {
      type: 'success',
      msg: 'プロフィール画像を削除しました'
    }
    render json: payload
  end

  private

  def user_params
    params.require(:user).permit(:name, :user_name, :email, :password)
  end
end
