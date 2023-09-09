RSpec.configure do |config|
  config.after(:suite) do
    Timecop.return
  end
end
