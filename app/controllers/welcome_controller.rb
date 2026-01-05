class WelcomeController < ApplicationController
  def index
    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])

    if @user.save
      session[:user_id] = @user.id
      redirect_to new_taste_profile_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
