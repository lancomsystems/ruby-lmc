# frozen_string_literal: true

require 'test_helper'
class LmcUserTest < Minitest::Test
  LMC::Cloud.debug = true
  @@credentials = LMC::Tests::CredentialsHelper.credentials.pwchange
  @@changecloud = LMC::Cloud.new(@@credentials.host, @@credentials.email, @@credentials.password)
  @@currentmillis = (Time.now.to_f * 1000).floor
  @@newpass = "Password-#{@@currentmillis.to_s}"

  def teardown
    user = LMC::User.new( 'email' => @@credentials.email,
                          'password' => @@credentials.password )
    LMC::Cloud.stub :instance, @@changecloud do
      begin
        user.update @@newpass
      rescue LMC::ResponseException => e
        raise e unless e.response.body.code == 107 # -> password is invalid
      end
    end
  end

  def test_user_pw_change
    user = LMC::User.new('email' => @@credentials.email, 'password' => @@newpass)
    assert_equal @@credentials.email, user.email
    LMC::Cloud.stub :instance, @@changecloud do
      result = user.update @@credentials.password
      assert_empty result
    end
  end

  def test_user_pw_change_fail
    user = LMC::User.new('email' => @@credentials.email, 'password' => 'short')
    assert_equal @@credentials.email, user.email
    LMC::Cloud.stub :instance, @@changecloud do
      ex = assert_raises Exception do
        user.update @@credentials.password
      end
      assert_match(/400 Bad Request.*/, ex.message)
    end
  end
end

