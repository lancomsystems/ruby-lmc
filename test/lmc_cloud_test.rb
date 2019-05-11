# frozen_string_literal: true

require 'test_helper'

class LmcCloudTest < Minitest::Test

  def test_that_it_can_get_account_objects
    cloud = LMC::Cloud.instance
    accounts = cloud.get_accounts_objects
    refute_empty accounts
    assert_instance_of LMC::Account, accounts.first
  end

  def test_backstage_infos
    cloud = LMC::Cloud.instance
    infos = cloud.get_backstage_serviceinfos
    refute_empty infos
  end

  def test_password_hidden
    cloud = LMC::Cloud.instance
    infos = cloud.inspect
    refute_match(/password/, infos)
  end

  def test_put
    fake_execute = lambda {|r|
      return OpenStruct.new({:bytesize => 0})
    }
    c = LMC::Cloud.instance
    ::RestClient::Request.stub :execute, fake_execute do
      response = c.put ['service', 'test'], {'this' => 'body'}
      assert_kind_of(LMC::LMCResponse, response)
    end
  end

  def test_protocol_selection
    cloud = LMC::Cloud.instance
    pre_state = LMC::Cloud.use_tls
    LMC::Cloud.use_tls=false
    http_url = cloud.build_url(['test', 'url'])
    assert_equal "http://#{LMC::Tests::CredentialsHelper.credentials.ok.host}/test/url", http_url
    cloud = LMC::Cloud.instance
    LMC::Cloud.use_tls=true
    http_url = cloud.build_url(['test', 'url'])
    assert_equal "https://#{LMC::Tests::CredentialsHelper.credentials.ok.host}/test/url", http_url
    LMC::Cloud.use_tls = pre_state
  end

end
