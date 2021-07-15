# frozen_string_literal: true

require 'test_helper'
class LmcUserTest < Minitest::Test
  def setup
    @credentials = LMC::Tests::CredentialsHelper.credentials.pwchange
  end

  def test_user_pw_reset
    LMC::Cloud.debug = true
    user = LMC::User.new('email' => @credentials.email)
    user.request_pw_reset
  end
end