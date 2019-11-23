# frozen_string_literal: true

require 'test_helper'
class LmcUUIDTest < Minitest::Test
  def test_valid_string
    valid_string = SecureRandom.uuid
    uuid = LMC::UUID.new valid_string
    assert_equal valid_string, uuid.to_s
  end

  def test_invalid_string
    invalid_string = "foobar"
    assert_raises Exception do
      uuid = LMC::UUID.new invalid_string
    end
  end
end