# frozen_string_literal: true

require 'test_helper'

class Lmc2FATest < Minitest::Test
  def setup
    @lmc = LMC::Cloud.allocate
  end

  def test_2fa_not_set
    mock = Minitest::Mock.new
    mock.expect :call, nil, [
      ['cloud-service-auth', 'userlogin'],
      { :name => 'admin',
        :password => 'test1234',
        :code => nil,
        :termsOfUse => [] }
    ]
    @lmc.stub :post, mock do
      @lmc.send :initialize, 'localhost', 'admin', 'test1234'
    end
    assert mock.verify
  end

  def test_2fa_code_missing_exception
    fake_method = lambda { |_args|
      bodystring = '{
    "timestamp": "2021-07-16T12:06:31.451Z",
    "service": "auth",
    "version": "9.24.4000",
    "status": 400,
    "path": "/userlogin",
    "code": 104,
    "details": {},
    "message": "Authentication error",
    "type": "DetailedProcessException"
}'
      e = Fixtures.restclient_exception bodystring, 400
      raise LMC::ResponseException.new(e.response), cause: e
    }
    @lmc.stub :execute_request, fake_method do
      assert_raises LMC::MissingCodeException do
        @lmc.send :initialize, 'localhost', 'admin', 'test1234'
      end
    end
  end

  def test_2fa_set
    mock = Minitest::Mock.new
    mock.expect :call, nil, [
      ['cloud-service-auth', 'userlogin'],
      { :name => 'admin',
        :password => 'test1234',
        :code => '123987',
        :termsOfUse => [] }
    ]
    @lmc.stub :post, mock do
      @lmc.send :initialize, 'localhost', 'admin', 'test1234', '123987'
    end
    assert mock.verify
  end
end

