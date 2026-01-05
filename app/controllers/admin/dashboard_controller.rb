class Admin::DashboardController < Admin::BaseController
  def index
    @users_count = User.count
    @coffees_count = Coffee.count
    @profiles_count = TasteProfile.count
  end
end
