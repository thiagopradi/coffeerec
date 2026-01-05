class Admin::MatchesController < Admin::BaseController
  def index
    @users = User.includes(:taste_profile).where.not(taste_profiles: { id: nil })
  end

  def show
    @user = User.find(params[:id])

    if @user.taste_profile.nil?
      redirect_to admin_matches_path, alert: "This user has no taste profile."
      return
    end

    engine = RecommendationEngine.new(@user.taste_profile)
    @recommendations = engine.call(limit: 10)
  end
end
