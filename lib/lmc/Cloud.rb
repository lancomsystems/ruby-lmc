# frozen_string_literal: true

require 'base64'
require 'json'
require 'restclient'

module LMC
  class Cloud
    class << self
      attr_accessor :cloud_host, :user, :password, :verbose, :debug, :verify_tls, :use_tls
      Cloud.use_tls = true
      Cloud.verify_tls = true
    end

    def self.instance(opts = { authorize: true })
      @@inst ||= new(@cloud_host, @user, @password, opts[:authorize])
    end

    attr_reader :auth_ok, :cloud_host, :user, :password

    def initialize(cloud_host, user, pass, auth = true)
      @auth_ok = false
      @cloud_host = cloud_host
      @user = user
      @password = pass
      @verify_tls = Cloud.verify_tls
      @last_authorized_account_ids = nil
      @logger ||= ::LMC::Logger.new(STDOUT) if Cloud.debug
      @logger.cloud = self if Cloud.debug
      RestClient.log = @logger if Cloud.debug
      authorize if auth
    end

    # hide password from dumps
    def inspect
      "#<Cloud:#{object_id}, #{build_url}>"
    end

    def get_backstage_serviceinfos
      get 'cloud-service-backstage/serviceinfos'
    end

    def get_accounts
      get 'cloud-service-auth/accounts'
    end

    def get_accounts_objects
      result = get ['cloud-service-auth', 'accounts']
      if result.code == 200
        accounts = result.map do |aj|
          Account.new(self, aj)
        end
      else
        raise "Unable to fetch accounts: #{result.body.message}"
      end

      accounts
    end

    def invite_user_to_account(email, account_id, type, authorities = [])
      body = { name: email, state: 'ACTIVE', type: type }
      body['authorities'] = authorities
      post ['cloud-service-auth', 'accounts', account_id, 'members'], body
    end

    def get(path, params = nil)
      prepared_headers = headers
      prepared_headers[:params] = params
      args = {
          :method => :get,
          :url => build_url(path),
          :headers => prepared_headers
      }
      execute_request args
    end

    def put(path, body_object)
      args = {
          :method => :put,
          :url => build_url(path),
          :payload => body_object.to_json

      }
      execute_request args
    end

    def post(path, body_object)
      args = {
          :method => :post,
          :url => build_url(path),
          :payload => body_object.to_json
      }
      execute_request args
    end

    def delete(path, params = nil)
      prepared_headers = headers
      prepared_headers[:params] = params
      args = {
          :method => :delete,
          :url => build_url(path),
          :headers => prepared_headers
      }
      execute_request args
    end

    ##
    # public accessors
    ##
    def session_token
      @auth_token['value']
    end

    def build_url(*path_components)
      protocol = 'https'
      if !Cloud.use_tls
        protocol = 'http'
      end
      ["#{protocol}://#{@cloud_host}", path_components].flatten.compact.join('/')
    end

    def auth_for_accounts(accounts)
      authorize(accounts)
    end

    def auth_for_account(account)
      authorize([account])
    end

    def accept_tos(tos)
      authorize([], tos)
    end

    private

    def authorize(accounts = [], tos = [])
      account_ids = accounts.map { |a|
        if a.respond_to? :id
          a.id
        else
          a
        end
      }
      if account_ids != @last_authorized_account_ids
        begin
          reply = post(['cloud-service-auth', 'auth'], name: @user, password: @password, accountIds: account_ids, termsOfUse: tos)
          @last_authorized_account_ids = account_ids
          @auth_token = reply
          @auth_ok = true
        rescue ::RestClient::ExceptionWithResponse => e
          response = JSON.parse(e.response.body)
          if response['code'] == 100
            raise LMC::OutdatedTermsOfUseException.new(response)
          end
        end
      end
    end

    def auth_bearer
      "Bearer #{session_token}"
    end

    def headers
      headers = {}
      headers[:content_type] = 'application/json'
      if @auth_ok
        headers[:Authorization] = auth_bearer
      end
      headers
    end

    def rest_options
      options = {}
      options[:verify_ssl] = false unless @verify_tls
      options
    end

    def execute_request(args)
      internal_args = { headers: headers }
      internal_args.merge! rest_options
      internal_args.merge! args
      begin
        resp = RestClient::Request.execute internal_args
        return LMCResponse.new(resp)
      rescue RestClient::ExceptionWithResponse => e
        if Cloud.debug
          puts 'EXCEPTION: ' + e.to_s
          puts 'EX.response: ' + e.response.to_s
          puts JSON.parse(e.response)['message']
        end
        raise e
      end
    end
  end
end

