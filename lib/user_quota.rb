class UserQuota
  attr_reader :user, :monthly_quota

  def initialize(user:, monthly_quota:)
    @user = user
    @monthly_quota = monthly_quota
  end

  def over_quota?
    start = Time.now.in_time_zone(user.time_zone).beginning_of_month
		user.hits.where('created_at > ?', start).count >= monthly_quota
  end
end
