require 'user_quota'

class ApplicationController < ActionController::API
  before_action :register_user_quota
  # around_action :set_time_zone

  def register_user_quota
    user_quota = UserQuota.new(
      user: current_user,
      monthly_quota: AppConfig.get(:monthly_quota),
      redis: Redis.new
    )
    render json: { error: 'over quota' } if user_quota.over_quota?
  end

  protected

  def current_user
    User.find(params[:user_id])
  end

  private

  def set_time_zone
    Time.use_zone(current_user.time_zone) { yield }
  end
end
