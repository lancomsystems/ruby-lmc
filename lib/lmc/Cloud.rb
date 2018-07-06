require 'base64'
require 'json'
require 'restclient'
begin
  require 'pry-nav'
rescue
end

module LMC
  class Cloud
    #include ActionView::Helpers::DateHelper

    class << self
      attr_writer :cloud_host, :user, :password
      attr_accessor :verbose, :debug, :verify_tls, :use_tls
      Cloud.use_tls = true
      Cloud.verify_tls = true
    end

    # def self.cloud_host=(cloud_host)
    #     @@cloud_host = cloud_host
    # end

    def self.instance(opts = {authorize: true})
      @@inst ||= self.new(@cloud_host, @user, @password, opts[:authorize])
    end


    attr_reader :auth_ok, :cloud_host

    def initialize(cloud_host, user, pass, auth=true)
      @auth_ok = false
      @cloud_host = cloud_host
      @user = user
      @password = pass
      @verify_tls = Cloud.verify_tls
      authorize if auth
    end

    # hide password from dumps
    def inspect
      "#<Cloud:#{object_id}, #{build_url}>"
    end

    def get_backstage_serviceinfos
      get "cloud-service-backstage/serviceinfos"
    end

    def get_accounts
      get "cloud-service-auth/accounts"
    end

    def get_accounts_objects
      result = get ["cloud-service-auth", "accounts"]
      if result.code == 200
        accounts = result.map do |aj|
          Account.new(aj)
        end
      else
        raise "Unable to fetch accounts: #{result.body.message}"
      end

      return accounts
    end

    # functionality should be moved to Account class
    #def get_account(name, type = nil)
    #  accounts = get_accounts_objects.select do |a|
    #    (name.nil? || a.name == name) && (type.nil? || a.type == type)
    #  end
    #  if accounts.length == 1
    #    return accounts[0]
    #  else
    #    raise "Did not specify exactly one account"
    #  end
    #end

    def invite_user_to_account(email, account_id, type, authorities = [])
      body = {name: email, state: "ACTIVE", type: type}
      body["authorities"] = authorities
      post ["cloud-service-auth", "accounts", account_id, 'members'], body
    end

    def get(path, params = nil)
      RestClient.log = ("stdout") if Cloud.debug
      begin
        prepared_headers = headers
        prepared_headers[:params] = params
        args = {
            :method => :get,
            :url => build_url(path),
            :headers => prepared_headers,
        }
        args.merge!(rest_options)
        resp = RestClient::Request.execute args
        return LMCResponse.new(resp)
      rescue RestClient::ExceptionWithResponse => e
        puts "EXCEPTION: " + e.to_s if Cloud.debug
        puts "EX.response: " + e.response.to_s if Cloud.debug
        puts JSON.parse(e.response)["message"] if Cloud.debug
        raise e
        #return LMCResponse.new(e.response)
      end
    end

    def put(path, body_object)
      RestClient.log = ("stdout") if Cloud.debug
      begin
        args = {
            :method => :put,
            :url => build_url(path),
            :payload => body_object.to_json,
            :headers => headers

        }
        args.merge!(rest_options)
        resp = RestClient::Request.execute args
        return LMCResponse.new(resp)
      rescue RestClient::ExceptionWithResponse => e
        puts "EXCEPTION: " + e.to_s if Cloud.debug
        puts "EX.response: " + e.response.to_s if Cloud.debug
        puts JSON.parse(e.response)["message"] if Cloud.debug
        return LMCResponse.new(e.response)
      end
    end

    def post(path, body_object)
      RestClient.log = ("stdout") if Cloud.debug
      begin
        args = {
            :method => :post,
            :url => build_url(path),
            :payload => body_object.to_json,
            :headers => headers

        }
        args.merge!(rest_options)
        resp = RestClient::Request.execute args
        return LMCResponse.new(resp)
      rescue RestClient::ExceptionWithResponse => e
        puts "EXCEPTION: " + e.to_s if Cloud.debug
        puts "EX.response: " + e.response.to_s if Cloud.debug
        puts JSON.parse(e.response)["message"] if Cloud.debug
        raise e
      end
    end

    def delete(path, body_object = nil)
      RestClient.log = ("stdout") if Cloud.debug
      begin
        args = {
            :method => :delete,
            :url => build_url(path),
            :payload => body_object.to_json,
            :headers => headers
        }
        args.merge!(rest_options)
        resp = RestClient::Request.execute args
        return LMCResponse.new(resp)
      rescue RestClient::ExceptionWithResponse => e
        puts "EXCEPTION: " + e.to_s if Cloud.debug
        puts "EX.response: " + e.response.to_s if Cloud.debug
        puts JSON.parse(e.response)["message"] if Cloud.debug
        return LMCResponse.new(e.response)
      end
    end

    ##
    # public accessors
    ##
    def session_token
      @auth_token["value"]
    end

    def build_url(*path_components)
      protocol = "https"
      if !Cloud.use_tls
        protocol = "http"
      end
      ["#{protocol}://#{@cloud_host}", path_components].flatten.compact.join("/")
    end

    def auth_for_accounts(account_ids)
      puts "Authorizing for accounts: " + account_ids.to_s if Cloud.debug
      authorize(account_ids)
    end

    def auth_for_account(account)
      auth_for_accounts([account.id])
    end

    def accept_tos(tos)
        authorize([], tos)
    end


    private
    def authorize(account_ids = [], tos = [])
      begin
        reply = post(["cloud-service-auth", "auth"], {name: @user, password: @password, accountIds: account_ids, termsOfUse: tos})
        puts "authorize reply " + reply.inspect if Cloud.debug
        @auth_token = reply
        @auth_ok = true
      rescue ::RestClient::ExceptionWithResponse => e
        response = JSON.parse(e.response.body)
        if response['code'] == 100
            raise LMC::OutdatedTermsOfUseException.new(response)
        end
      end
    end

    def auth_bearer
      "Bearer " + session_token
    end

    def headers
      headers = {}
      headers[:content_type] = 'application/json'
      if @auth_ok
        headers[:Authorization] = auth_bearer
      end
      return headers
    end

    def rest_options
      options = {}
      if !@verify_tls
        options[:verify_ssl] = false
      end
      return options
    end
  end

end
