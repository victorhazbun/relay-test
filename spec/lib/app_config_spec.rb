require 'rails_helper'
require 'app_config'

describe AppConfig do
  subject(:app_config) { described_class }

  describe '#get' do
    context 'when key exists' do
      it 'returns the value for the given config key' do
        expect(app_config.get(:monthly_quota)).to eq(10_000)
      end
    end
    context 'when key does not exists' do
      it 'returns nil' do
        expect(app_config.get(:does_not_exists)).to be_nil
      end
    end
  end
end
