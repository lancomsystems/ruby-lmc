# frozen_string_literal: true

require 'test_helper'

class LmcLoginTest < Minitest::Test
  @@fake_post = lambda { |url, body|
    e = ::RestClient::ExceptionWithResponse.new
    e.response = OpenStruct.new('body' => '{"code":400,"service":"auth","message":"Expired terms-of-use","timestamp":"2018-06-29T17:54:59.095+02:00","path":"/auth","details":{"missing":[{"name":"organization","acceptance":"2018-06-25","updated":true}]},"type":"de.lcs.lmc.service.auth.exception.DetailedProcessException"}')
    raise e
  }

  def test_login_exception
    c = LMC::Cloud.instance
    c.stub :post, @@fake_post do
      assert_raises(RestClient::ExceptionWithResponse) do
        c.auth_for_accounts [SecureRandom.uuid]
      end
    end
  end
end
