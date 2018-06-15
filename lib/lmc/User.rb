module LMC
  class User
    #todo: look into hiding password
    attr_reader :email

    def initialize(data)
      @email = data["email"]
      @password = data["password"]
    end

    # current registration process unclear and likely to have changed
    # since this code was written.
    #def register()
    #    # cloud instance by default authenticates.
    #    # for registration specifically, no authentication is required
    #    # should be possible without email and password for "admin" user
    #    cloud = Cloud.instance
    #    cloud.post ["cloud-service-auth", "users"], {"password" => @password, "email" => @email}
    #end

    def update(old_pw)
      cloud = Cloud.instance
      begin
        cloud.post ["cloud-service-auth", "users", "self", "password"], {"password" => @password, 'verification' => old_pw}
      rescue RestClient::BadRequest => e
        response_body = JSON.parse(e.response)
        raise "#{e.message} - #{response_body['message']}"
      end
    end

    def request_pw_reset
      #https://beta.cloud.lancom.de/cloud-service-auth/actions
      cloud = Cloud.instance
      post_data = {"type" => "PASSWORD_RESET", "name" => @email}
      cloud.post ["cloud-service-auth", "actions"], post_data
    end

  end

end