require 'rails_helper'
require 'app_config'

RSpec.describe 'Hits', type: :request do
  let(:au_country_code) { :au }

  describe 'GET /users/:user_id/hits/:id' do
    before do
      ApplicationRecord.connected_to(role: :writing, shard: au_country_code) do
        @user = User.create!
        @hit_a = @user.hits.create!(endpoint: 'a.domain.com')
        @hit_b = @user.hits.create!(endpoint: 'b.domain.com')
        @hit_c = @user.hits.create!(endpoint: 'c.domain.com')
      end
      allow(AppConfig).to receive(:get).with(:monthly_quota).and_return(monthly_quota)
      get "/user/#{@user.id}/hits/#{@hit_a.id}", params: { country_code: :au }
    end

    around do |example|
      ApplicationRecord.connected_to(role: :reading, shard: au_country_code) { example.run }
    end

    context 'when exceeding the quota' do
      let(:monthly_quota) { 3 }

      it 'returns an over quota error' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('over quota')
      end
    end

    context 'when not exceeding the quota' do
      let(:monthly_quota) { 4 }

      it 'returns a JSON response with the hit data' do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(@hit_a.id)
      end
    end
  end
end
