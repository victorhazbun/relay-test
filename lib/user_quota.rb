# UserQuota represents a utility class for managing monthly quotas for a user using Redis.
# It provides methods to check if the user has exceeded their monthly quota and to increment
# the usage count.
class UserQuota
  attr_reader :redis, :redis_key, :monthly_quota

  # Initialize a new UserQuota instance.
  #
  # @param user [User] The user for whom the quota is managed.
  # @param monthly_quota [Integer] The maximum monthly quota allowed for the user.
  # @param redis [Redis] The Redis client used for quota tracking.
  def initialize(user:, monthly_quota:, redis:)
    @user = user
    @monthly_quota = monthly_quota
    @redis = redis
    @redis_key = "users:#{user.id}:monthly_hits_count"
  end

  # Increases the counter and checks if the user has exceeded their monthly quota.
  #
  # @return [Boolean] True if the user has exceeded the quota, false otherwise.
  def over_quota?
    redis.multi do
      redis.incr(redis_key)
      redis.expireat(redis_key, Time.current.end_of_month.to_i)
    end
    redis.get(redis_key).to_i > monthly_quota
  end
end
