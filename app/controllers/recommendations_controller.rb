class RecommendationsController < ApplicationController
  before_action :require_profile

  def index
    engine = RecommendationEngine.new(current_user.taste_profile)
    @recommendations = engine.call(limit: 3)
  end

  private

  def require_profile
    if current_user.nil?
      redirect_to root_path, alert: "Please enter your email first"
    elsif current_user.taste_profile.nil?
      redirect_to new_taste_profile_path, alert: "Please complete the quiz first"
    end
  end
end
