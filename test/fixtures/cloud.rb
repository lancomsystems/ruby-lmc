# frozen_string_literal: true
module Fixtures
  def self.cloud
    cld = LMC::Cloud.allocate
    cld.stub :post, Fixtures.test_response({ 'value' => 'AUTHTOKEN' }) do
      cld.send :initialize, 'localhost', 'admin', 'test1234'
    end
    cld
  end

  def self.mock_lmc(expects = [])
    mock = Minitest::Mock.new
    expects.each do |expect_args|
      mock.expect(*expect_args)
    end
    mock
  end
end

