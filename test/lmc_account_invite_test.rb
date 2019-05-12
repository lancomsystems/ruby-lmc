# frozen_string_literal: true

require 'test_helper'
class LmcAccountInviteTest < Minitest::Test
  TEST_ORGA = 'ruby-lmc'
  TEST_EMAIL = LMC::Tests::CredentialsHelper.credentials.ok.invite_test_address

  def setup
    @new_orga_member_id = nil
    @orga = LMC::Account.get_by_name TEST_ORGA
    @project = LMC::Account.new(LMC::Cloud.instance, 'parent' => @orga.id, 'name' => 'inviteproject', 'type' => 'PROJECT').save

  end

  def teardown
    @project.delete!
    @orga.remove_membership @new_orga_member_id if @new_orga_member_id
  end

  def test_authorities
    refute_nil @orga.authorities
    refute_empty @project.authorities
    assert_raises RuntimeError do
      LMC::Account.new(LMC::Cloud.instance,id: 'invalid_id').authorities
    end
  end

  def test_invite_project
    authorities = @project.authorities
    authorities.inspect
    chosen_authoritiy_ids = authorities.select { |a| a.name == 'PROJECT_VIEWER' }.map { |a| a.id }
    response = LMC::Cloud.instance.invite_user_to_account TEST_EMAIL,
                                                          @project.id,
                                                          'MEMBER',
                                                          chosen_authoritiy_ids
    refute_nil response
  end

  def test_invite_orga
    response = LMC::Cloud.instance.invite_user_to_account TEST_EMAIL, @orga.id, 'OWNER', []
    refute_nil response
    @new_orga_member_id = response.body.id
  end
end
