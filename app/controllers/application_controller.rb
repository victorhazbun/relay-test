class ApplicationController < ActionController::API
  before_action :user_quota

	def user_quota
    if user_quota.over_quota?
		  render json: { error: 'over quota' }
    else
      user_quota.increment
    end
  end

  protected

  def current_user
    User.find(params[:user_id])
  end

  private

  def user_quota
    @user_quota ||= UserQuota.new(
      user: current_user,
      monthly_quota: AppConfig.get(:monthly_quota),
      redis: Redis.new
    )
  end
end
