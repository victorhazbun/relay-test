require 'rails_helper'
require 'app_config'

RSpec.describe 'Products', type: :request do
  describe 'GET /users/:user_id/products/:id' do
    let(:user) { User.create!(time_zone: 'Australia/Brisbane') }
    let(:monthly_quota) { 100 }
    let(:redis) { MockRedis.new }

    before do
      Timecop.freeze(Time.zone.parse('2022-10-31 23:59:17 +1000'))
      now = Time.current
      current_month = now.beginning_of_month.month
      current_year = now.beginning_of_month.year
      redis_key = "monthly_hits:#{user.id}:#{current_month}:#{current_year}"
      redis.set(redis_key, hits)
      allow(Redis).to receive(:new).and_return(redis)
      allow(AppConfig).to receive(:get).with(:monthly_quota).and_return(monthly_quota)
    end

    context 'when quota resets for Australians' do
      let(:hits) { monthly_quota }
      let(:id) { 1 }

      it 'returns a JSON response with the hit data' do
        # FIX: No longer returns over quota error
        Timecop.freeze(Time.zone.parse('2022-11-01 01:12:54 +1000')) do
          get "/user/#{user.id}/products/#{id}"

          json_response = JSON.parse(response.body)
          expect(json_response['table']['id']).to eq(id)
        end
      end
    end
  end
end
