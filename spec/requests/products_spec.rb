require 'rails_helper'
require 'app_config'

RSpec.describe 'Products', type: :request do
  describe 'GET /users/:user_id/products/:id' do
    let(:user) { User.create!(time_zone: 'Australia/Brisbane') }
    let(:monthly_quota) { 100 }
    let(:redis) { MockRedis.new }
    let(:id) { 1 }

    before do
      Timecop.freeze(Time.zone.parse('2022-10-31 23:59:17 +1000'))
      redis_key = "users:#{user.id}:monthly_hits_count"
      redis.set(redis_key, hits)
      allow(Redis).to receive(:new).and_return(redis)
      allow(AppConfig).to receive(:get).with(:monthly_quota).and_return(monthly_quota)
      allow(AppConfig).to receive(:get).with(:over_quota_error_message).and_call_original
    end

    context 'when quota resets for Australians' do
      let(:hits) { monthly_quota }

      it 'returns a JSON response with the hit data' do
        # FIX: No longer returns over quota error
        redis.expire("users:#{user.id}:monthly_hits_count", 0)
        Timecop.freeze(Time.zone.parse('2022-11-01 01:12:54 +1000')) do
          get "/user/#{user.id}/products/#{id}"

          json_response = JSON.parse(response.body)
          expect(json_response['table']['id']).to eq(id)
        end
      end
    end

    context 'when making concurrent requests' do
      let(:hits) { 0 }
      let(:monthly_quota) { 12 }
      let(:concurrent_requests) { 4 }
      let(:threads) { [] }
      let(:results) { [] }

      it 'does not exceed the monthly quota' do
        # Start multiple threads to simulate concurrent requests
        # 4 threads and 3 requests per thread = 12 requests (succeed)
        # 4 threads and 1 extra request per thread = 4 requests (fail).
        concurrent_requests.times do |i|
          threads << Thread.new do
            # Simulate hits created by different threads
            hits_to_create = (monthly_quota / concurrent_requests) + 1
            hits_to_create.times do
              get "/user/#{user.id}/products/#{id}"
              results << JSON.parse(response.body)
            end
          end
        end

        # Wait for all threads to finish
        threads.each(&:join)

        # Ensure that results are successful responses
        expect(results.count { |entry| entry.key?('table') }).to eq(monthly_quota)
        # Any subsequent response will be error based on monthly quota.
        expect(results.count { |entry| entry.key?('error') }).to eq(concurrent_requests)
      end
    end
  end
end
