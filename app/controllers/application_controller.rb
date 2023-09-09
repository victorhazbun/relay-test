require 'user_quota'
class ApplicationController < ActionController::API
  before_action :user_quota

	def user_quota
		render json: { error: 'over quota' } if over_quota?
  end

  protected

  def current_user
    country_code = params[:country_code].to_sym || :us
    ApplicationRecord.connected_to(role: :reading, shard: country_code) do
      User.find(params[:user_id])
    end
  end

  private

  def over_quota?
    UserQuota.new(user: current_user, monthly_quota: AppConfig.get(:monthly_quota)).over_quota?
  end
end
