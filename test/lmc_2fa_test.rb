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
    fake_post = lambda { |_url, _body|
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
      raise e
    }
    @lmc.stub :post, fake_post do
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

