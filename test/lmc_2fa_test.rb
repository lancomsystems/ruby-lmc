# frozen_string_literal: true

require 'test_helper'
class Lmc2FATest < Minitest::Test
  @@fake_post = lambda { |url, body|
    e = ::RestClient::ExceptionWithResponse.new
    e.response = OpenStruct.new('body' => '{"code":100,"service":"auth","message":"Expired terms-of-use","timestamp":"2018-06-29T17:54:59.095+02:00","path":"/auth","details":{"missing":[{"name":"organization","acceptance":"2018-06-25","updated":true}]},"type":"de.lcs.lmc.service.auth.exception.DetailedProcessException"}')
    raise e
  }
  def setup
    @lmc = Fixtures.cloud
  end

  def test_2fa_not_set
    cld = LMC::Cloud.allocate
    mock = Minitest::Mock.new
    mock.expect :call, nil, [
        ['cloud-service-auth', 'auth'],
        { :name => 'admin',
         :password => 'test1234',
         :code => nil,
         :accountIds => [],
         :termsOfUse => [] }
    ]
    cld.stub :post, mock do
      cld.send :initialize, 'localhost', 'admin', 'test1234'
    end
    assert mock.verify
  end

  def test_2fa_set
    cld = LMC::Cloud.allocate
    mock = Minitest::Mock.new
    mock.expect :call, nil, [
        ['cloud-service-auth', 'auth'],
        { :name => 'admin',
         :password => 'test1234',
         :code => '123987',
         :accountIds => [],
         :termsOfUse => [] }
    ]
    cld.stub :post, mock do
      cld.send :initialize, 'localhost', 'admin', 'test1234', '123987'
    end
    assert mock.verify
  end
end

