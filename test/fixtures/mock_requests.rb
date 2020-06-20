# frozen_string_literal: true
module Fixtures
  def self.mock_execute(expects = [])
    mock = Minitest::Mock.new
    expects.each do |expect_args|
      mock.expect(*expect_args)
    end
    mock
  end
end

