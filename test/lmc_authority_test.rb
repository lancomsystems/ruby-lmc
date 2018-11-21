# frozen_string_literal: true

require 'test_helper'
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
      return OpenStruct.new({:body => "FAAKE"})
    }
    c = LMC::Cloud.instance
    c.stub :get, fake_get do
      assert_equal "FAAKE", authority.rights
    end
  end

  def test_authority_save
    mock_response = Minitest::Mock.new
    response_body = {'id' => '6b631c6a-d751-415e-be9f-6f5fcb7377f7',
                           'name' => 'testauthority',
                           'type' => 'STATIC',
                           'visibility' => 'Private'}
    mock_response.expect :body, response_body
    mock_lmc = Minitest::Mock.new
    mock_lmc.expect :post, mock_response, [["cloud-service-auth", "accounts", "5ba017ae-fff1-4495-8d84-0bf30ace4c04", "authorities"], LMC::Authority]
    LMC::Cloud.stub :instance, mock_lmc do
      account = LMC::Account.new 'id' => '5ba017ae-fff1-4495-8d84-0bf30ace4c04'
      authority = LMC::Authority.new({'name' => 'testauthority', 'visibility' => 'PRIVATE'}, account)
      authority.save
      assert_equal response_body['id'], authority.id

      no_update = assert_raises RuntimeError do
        authority = LMC::Authority.new({'name' => 'foo', 'id' => '3eca1816-a6cf-49b5-b251-5fc42e85223b'}, account)
        authority.save
      end
      assert_equal 'editing authorities not supported', no_update.message
    end
  end
end
