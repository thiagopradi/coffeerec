class TasteProfilesController < ApplicationController
  before_action :require_user

  def new
    @taste_profile = current_user.taste_profile || current_user.build_taste_profile
  end

  def create
    # Destroy existing taste profile if user is retaking the quiz
    current_user.taste_profile&.destroy

    @taste_profile = current_user.build_taste_profile(taste_profile_params)

    if @taste_profile.save
      # Ensure user is authenticated in the session
      session[:user_id] = current_user.id
      redirect_to recommendations_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def taste_profile_params
    params.require(:taste_profile).permit(
      :chocolate_preference, :fruit_preference, :drink_preference,
      :texture_preference, :adventure_level, :brewing_method, :has_grinder
    )
  end

  def require_user
    redirect_to root_path, alert: "Please enter your email first" unless current_user
  end
end
