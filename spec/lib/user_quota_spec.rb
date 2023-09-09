require 'rails_helper'
require 'user_quota'

describe UserQuota do
  let(:au_country_code) { :au }

  before do
    ApplicationRecord.connected_to(role: :writing, shard: au_country_code) do
      @user = User.create!
      5.times { @user.hits.create! }
    end
  end

  around do |example|
    ApplicationRecord.connected_to(role: :reading, shard: au_country_code) { example.run }
  end

  subject(:user_quota) { described_class.new(user: @user, monthly_quota: monthly_quota) }

  describe '#over_quota?' do
    context 'when user hits count is greater than the max quota' do
      let(:monthly_quota) { 4 }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is equal to the max quota' do
      let(:monthly_quota) { 5 }

      it { expect(user_quota.over_quota?).to be_truthy }
    end

    context 'when user hits count is less than the max quota' do
      let(:monthly_quota) { 6 }

      it { expect(user_quota.over_quota?).to be_falsey }
    end
  end
end
