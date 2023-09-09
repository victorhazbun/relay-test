require 'rails_helper'
require 'user_quota'

describe UserQuota do
  let(:user) { User.create! }
  let(:redis) { MockRedis.new }
  let(:now) { Time.current }
  let(:current_month) { now.beginning_of_month.month }
  let(:current_year) { now.beginning_of_month.year }
  let(:redis_key) { "monthly_hits:#{user.id}:#{current_month}:#{current_year}" }
  let(:monthly_quota) { 100 }

  before do
    redis.set(redis_key, hits)
  end

  subject(:user_quota) { described_class.new(user:, monthly_quota:, redis:) }

  describe '#over_quota?' do
    context 'when user hits count is greater than the max quota' do
      let(:hits) { 101 }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is equal to the max quota' do
      let(:hits) { 100 }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is less than the max quota' do
      let(:hits) { 98 }

      it { expect(user_quota.over_quota?).to be_falsey }
    end
  end
end
