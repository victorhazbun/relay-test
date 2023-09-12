require 'rails_helper'
require 'user_quota'

describe UserQuota do
  let(:user) { User.create! }
  let(:redis) { MockRedis.new }
  let(:redis_key) { "users:#{user.id}:monthly_hits_count" }
  let(:monthly_quota) { 100 }

  before { redis.set(redis_key, hits) }

  subject(:user_quota) { described_class.new(user:, monthly_quota:, redis:) }

  describe '#over_quota?' do
    context 'when user hits count is greater than the max quota' do
      let(:hits) { monthly_quota + 1 }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is equal to the max quota' do
      let(:hits) { monthly_quota }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is less than the max quota' do
      let(:hits) { monthly_quota - 1 }

      it { expect(user_quota.over_quota?).to be_falsey }
    end

    context 'when quota expires' do
      let(:hits) { monthly_quota }
      let(:original_time) { Time.current }

      it 'resets and increment the quota' do
        Timecop.freeze(original_time) do
          user_quota.over_quota?
        end

        Timecop.travel(original_time.end_of_month + 3.days) do
          expect { user_quota.over_quota? }.to change { redis.get(redis_key) }.from(nil).to("1")
        end
      end
    end
  end
end
