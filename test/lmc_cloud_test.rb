# frozen_string_literal: true

require 'test_helper'

class LmcCloudTest < Minitest::Test
  def setup
    @lmc = LMC::Cloud.new 'example.com', 'user', 'papa', nil, false
  end

  def test_that_it_can_get_account_objects
    cloud = LMC::Cloud.instance
    accounts = cloud.get_accounts_objects
    refute_empty accounts
    assert_instance_of LMC::Account, accounts.first
  end

  def test_that_account_failures_are_raised
    mock_response = Fixtures.test_response({ 'message' => 'failed' }, 500)
    @lmc.stub :get, mock_response do
      ex = assert_raises RuntimeError do
        @lmc.get_accounts_objects
      end
      assert_equal 'Unable to fetch accounts: failed', ex.to_s
    end
  end

  def test_unhandled_login_failures_are_raised
    lmc = LMC::Cloud.allocate
    fake_post = lambda { |_url, _body|
      bodystring = '{
    "timestamp": "2021-07-16T12:06:31.451Z",
    "service": "auth",
    "version": "9.24.4000",
    "status": 400,
    "path": "/userlogin",
    "code": 199,
    "details": {},
    "message": "Authentication error",
    "type": "DetailedProcessException"
    }'
      e = Fixtures.restclient_exception bodystring, 400
      raise e
    }
    lmc.stub :post, fake_post do
      assert_raises RuntimeError do
        lmc.send :initialize, 'localhost', 'admin', 'test1234'
      end
    end

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
    fake_execute = lambda { |_r|
      return OpenStruct.new(:bytesize => 0)
    }
    c = LMC::Cloud.instance
    ::RestClient::Request.stub :execute, fake_execute do
      response = c.put ['service', 'test'], 'this' => 'body'
      assert_kind_of(LMC::LMCResponse, response)
    end
  end

  def test_delete
    fake_execute = Minitest::Mock.new
    fake_execute.expect :call,
                        Fixtures.test_restclient_response(''), [Hash]
    fake_execute.expect :call,
                        Fixtures.test_restclient_response('') do |args|
      assert_equal args[:method], :delete
      assert_equal args[:url], 'https://example.com/foo'
      assert_equal args[:headers], { :content_type => 'application/json',
                                     :params => { :ids => ['12', '23'] } }
    end
    @lmc.stub :execute_request, fake_execute do
      @lmc.delete ['foo']
      @lmc.delete ['foo'], { ids: ['12', '23'] }
    end
    assert fake_execute.verify
  end

  def test_protocol_selection
    cloud = LMC::Cloud.instance
    pre_state = LMC::Cloud.use_tls
    LMC::Cloud.use_tls = false
    http_url = cloud.build_url(['test', 'url'])
    assert_equal "http://#{LMC::Tests::CredentialsHelper.credentials.ok.host}/test/url", http_url
    cloud = LMC::Cloud.instance
    LMC::Cloud.use_tls = true
    http_url = cloud.build_url(['test', 'url'])
    assert_equal "https://#{LMC::Tests::CredentialsHelper.credentials.ok.host}/test/url", http_url
    LMC::Cloud.use_tls = pre_state
  end

  def test_exception_logging
    fake_execute = lambda { |_r|
      response = RestClient::Response.create '{"message": "FAIL"}', Net::HTTPResponse.new('', '200', ''), RestClient::Request.new({ :method => :post, url: 'http://localhost/' })
      ex = RestClient::ExceptionWithResponse.new response, 500
      ex.message = 'buh'
      raise ex
    }

    fake_puts = Minitest::Mock.new
    fake_puts.expect :call, nil, ['EXCEPTION: buh']
    fake_puts.expect :call, nil, ['EX.response: {"message": "FAIL"}']
    fake_puts.expect :call, nil, ['FAIL']

    LMC::Cloud.stub :debug, true do
      @lmc.stub :puts, fake_puts, String do
        RestClient::Request.stub :execute, fake_execute do
          assert_raises LMC::ResponseException do
            @lmc.get []
          end
        end
      end
    end
  end
end

