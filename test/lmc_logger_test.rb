# frozen_string_literal: false

require 'test_helper'
class LmcLoggerTest < Minitest::Test
  def setup
    lmc = Fixtures.mock_lmc
    lmc.expect :password, 'password'
    @capture_stringio = StringIO.new
    @logger = LMC::Logger.new @capture_stringio
    @logger.cloud = lmc
  end

  def test_password
    @logger << 'foopasswordbar'
    assert_equal 'foo********bar', @capture_stringio.string
  end

  def test_auth_token
    @logger << 'RestClient.get "https://beta.cloud.lancom.de/cloud-service-backstage/serviceinfos", "Accept"=>"*/*", "Accept-Encoding"=>"gzip, deflate", "Authorization"=>"Bearer eyJhbGciOiJIUzI1NYTQtYjM5ZC05MGMxMTQwMjRlYzgiLCJleHBpcmVzIjoxNTc0NjI0NTU0Nzc3LCJwcmluY2lwYWxOYW1lIjoicGhpbGlwcC5lcmJlbGRpbmdAbGFuY29tLmRlIiwic2Vzc2lvbiI6IjRjODNiMWI3LTcwZjUtNDY5ZC1hZjdjLWM2OTNiZDY2OGEyMiIsImxhbmciOiJkZSJ9.zex1-9SLPHxhtsPUvY7mmGfVm4mlhyewwxmbZhocxFY", "Content-Type"=>"application/json", "Params"=>"", "User-Agent"=>"rest-client/2.0.2 (darwin17.4.0 x86_64) ruby/2.4.1p111"
'
    refute_includes @capture_stringio.string, 'eyJhbGciOiJIUzI1NYTQtYjM5ZC05MGMxMTQwMjRlYzgiLCJleHBpcmVzIjoxNTc0NjI0NTU0Nzc3LCJwcmluY2lwYWxOYW1lIjoicGhpbGlwcC5lcmJlbGRpbmdAbGFuY29tLmRlIiwic2Vzc2lvbiI6IjRjODNiMWI3LTcwZjUtNDY5ZC1hZjdjLWM2OTNiZDY2OGEyMiIsImxhbmciOiJkZSJ9.zex1-9SLPHxhtsPUvY7mmGfVm4mlhyewwxmbZhocxFY'
    assert_match /TOKEN REDACTED/, @capture_stringio.string
  end
end

