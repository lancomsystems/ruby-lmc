require 'test_helper'
class LmcTosTest < Minitest::Test

  @@fake_post = lambda { |url, body|
    e = ::RestClient::ExceptionWithResponse.new
    e.response = OpenStruct.new({"body" => '{"code":100,"service":"auth","message":"Expired terms-of-use","timestamp":"2018-06-29T17:54:59.095+02:00","path":"/auth","details":{"missing":[{"name":"organization","acceptance":"2018-06-25","updated":true}]},"type":"de.lcs.lmc.service.auth.exception.DetailedProcessException"}'})
    raise e
  }
  def test_tos_exception
    c = LMC::Cloud.instance
    c.stub :post, @@fake_post do
      assert_raises(LMC::OutdatedTermsOfUseException) do

        c.auth_for_accounts []
      end
    end
  end

  def test_tos_exception_response
    c = LMC::Cloud.instance
    c.stub :post, @@fake_post do
      begin
        c.auth_for_accounts []
      rescue LMC::OutdatedTermsOfUseException => e
        assert_equal "Terms of use must be accepted before using this LMC instance:\nName: organization, Date 2018-06-25\n",  e.response
        assert_equal 1, e.missing.size

      end
    end
  end


end
