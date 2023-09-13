module RelayTest
  def self.redis
    @redis ||= ConnectionPool::Wrapper.new do
      Redis.new
    end
  end
end
