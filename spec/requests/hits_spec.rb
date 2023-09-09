require 'rails_helper'
require 'app_config'

RSpec.describe 'Hits', type: :request do
  let(:au_country_code) { :au }
  let(:current) { Time.current }

  describe 'GET /users/:user_id/hits/:id' do
    before do
      Timecop.freeze(Time.zone.parse('2022-10-31 23:59:17 +1000'))
      ApplicationRecord.connected_to(role: :writing, shard: au_country_code) do
        @user = User.create!(time_zone: 'Australia/Brisbane')
        @hit_a = @user.hits.create!(endpoint: 'a.domain.com')
        @hit_b = @user.hits.create!(endpoint: 'b.domain.com')
        @hit_c = @user.hits.create!(endpoint: 'c.domain.com')
      end
      allow(AppConfig).to receive(:get).with(:monthly_quota).and_return(monthly_quota)
    end

    around do |example|
      ApplicationRecord.connected_to(role: :reading, shard: au_country_code) { example.run }
    end

    context 'when exceeding the quota' do
      let(:monthly_quota) { 3 }

      it 'returns an over quota error' do
        get "/user/#{@user.id}/hits/#{@hit_a.id}", params: { country_code: :au }

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('over quota')
      end
    end

    context 'when not exceeding the quota' do
      let(:monthly_quota) { 4 }

      it 'returns a JSON response with the hit data' do
        get "/user/#{@user.id}/hits/#{@hit_a.id}", params: { country_code: :au }

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(@hit_a.id)
      end
    end

    context 'when quota resets for Australians' do
      let(:monthly_quota) { 3 }


      it 'returns a JSON response with the hit data' do
        # FIX: No longer returns over quota error
        Timecop.freeze(Time.zone.parse('2022-11-01 01:12:54 +1000')) do
          get "/user/#{@user.id}/hits/#{@hit_a.id}", params: { country_code: :au }

          json_response = JSON.parse(response.body)
          expect(json_response['id']).to eq(@hit_a.id)
        end
      end
    end
  end
end
