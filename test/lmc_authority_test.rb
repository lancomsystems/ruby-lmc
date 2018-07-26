require 'test_helper'
require 'securerandom'
class LmcAuthorityTest < ::Minitest::Test
  def test_authority_aux
    account = LMC::Account.new({"id" => SecureRandom.uuid})
    authority = LMC::Authority.new(
        {"name" => "ein name", "type" => "CUSTOM", "visibility" => "PUBLIC"}, account)
    assert_equal("ein name (CUSTOM/PUBLIC)", authority.to_s)
    assert_equal '{"name":"ein name","type":"CUSTOM","visibility":"PUBLIC"}', authority.to_json
  end

  def test_authority_rights
    account = LMC::Account.new({"id" => SecureRandom.uuid})
    authority = LMC::Authority.new(
        {"name" => "ein name", "type" => "CUSTOM", "visibility" => "PUBLIC"}, account)

    fake_get = lambda {|r|
      puts r
      return OpenStruct.new({:body => "FAAKE"})
    }
    c = LMC::Cloud.instance
    c.stub :get, fake_get do
      assert_equal "FAAKE", authority.rights
    end
  end
end
