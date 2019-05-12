# frozen_string_literal: true

require 'test_helper'
class LmcUserTest < Minitest::Test
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
      rescue RuntimeError => e
        raise e unless e.message == '400 Bad Request - Current password does not match'
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
      ex = assert_raises RuntimeError do
        user.update @@credentials.password
      end
      assert_match(/400 Bad Request.*/, ex.message)
    end
  end

  def test_user_pw_reset
    user = LMC::User.new('email' => @@credentials.email)
    user.request_pw_reset
  end
end
