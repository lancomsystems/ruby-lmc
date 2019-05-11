# frozen_string_literal: true

require 'test_helper'
class LmcTosTest < Minitest::Test
  @@fake_post = lambda {|url, body|
    e = ::RestClient::ExceptionWithResponse.new
    e.response = OpenStruct.new({'body' => '{"code":100,"service":"auth","message":"Expired terms-of-use","timestamp":"2018-06-29T17:54:59.095+02:00","path":"/auth","details":{"missing":[{"name":"organization","acceptance":"2018-06-25","updated":true}]},"type":"de.lcs.lmc.service.auth.exception.DetailedProcessException"}'})
    raise e
  }

  def test_tos_exception
    c = LMC::Cloud.instance
    c.stub :post, @@fake_post do
      assert_raises(LMC::OutdatedTermsOfUseException) do

        c.auth_for_accounts [SecureRandom.uuid]
      end
    end
  end

  def test_tos_exception_response
    c = LMC::Cloud.instance
    c.stub :post, @@fake_post do
      begin
        c.auth_for_accounts [SecureRandom.uuid]
      rescue LMC::OutdatedTermsOfUseException => e
        assert_equal "Terms of use must be accepted before using this LMC instance:\nName: organization, Date 2018-06-25\n", e.response
        assert_equal 1, e.missing.size

      end
    end
  end

  def test_accept_tos
    tos_hash = {'name' => 'GENERAL', 'acceptance' => '2000-01-01'}
    mock = Minitest::Mock.new
    mock.expect :call, nil, [[], [tos_hash]]
    LMC::Cloud.instance.stub :authorize, mock do
      LMC::Cloud.instance.accept_tos([tos_hash])
    end
  end
end
