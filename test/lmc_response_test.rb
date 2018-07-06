require 'test_helper'
class LmcResponseTest < Minitest::Test
  def test_response_error_handling
    good_mock = Minitest::Mock.new
    good_mock.expect :bytesize, 2
    good_mock.expect :body, '{}'
    good_mock.expect :code, 200
    good_mock.expect :headers, []

    LMC::LMCResponse.new(good_mock)
    bad_mock = Minitest::Mock.new
    bad_mock.expect :bytesize, 2
    bad_mock.expect :body, '""'
    bad_mock.expect :code, 200
    bad_mock.expect :headers, []

    err = assert_raises RuntimeError do
      LMC::LMCResponse.new(bad_mock)
    end
    assert_match(/Unknown json parse result/, err.message)
  end

  def test_response_each
    array_mock = MiniTest::Mock.new
    array_mock.expect :bytesize, 6
    array_mock.expect :body, '[1, 2]'
    array_mock.expect :code, 200
    array_mock.expect :headers, []

    response = LMC::LMCResponse.new array_mock
    response.each {|num|}
  end

  def test_response_to_string
    array_mock = MiniTest::Mock.new
    array_mock.expect :bytesize, 6
    array_mock.expect :body, '[1, 2]'
    array_mock.expect :code, 200
    array_mock.expect :headers, []

    response = LMC::LMCResponse.new array_mock
    assert_equal "Response: Code: 200, Body: #{[1, 2].to_s}", response.to_s
  end

  def test_response_boolean
    response_mock = Minitest::Mock.new
    response_mock.expect :bytesize, 4
    response_mock.expect :body, "true"
    response_mock.expect :code, 200
    response_mock.expect :headers, []
    response = LMC::LMCResponse.new response_mock
    assert response.body
  end
end
