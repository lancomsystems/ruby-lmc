# frozen_string_literal: true

module LMC
  class User
    # TODO: look into hiding password
    attr_reader :email

    def initialize(data)
      @email = data['email']
      @password = data['password']
    end

    # current registration process unclear and likely to have changed
    # since this code was written.
    # def register()
    #    # cloud instance by default authenticates.
    #    # for registration specifically, no authentication is required
    #    # should be possible without email and password for "admin" user
    #    cloud = Cloud.instance
    #    cloud.post ["cloud-service-auth", "users"], {"password" => @password, "email" => @email}
    # end

    def update(old_pw)
      cloud = Cloud.instance
      cloud.post ['cloud-service-auth', 'users', 'self', 'password'], 'password' => @password, 'verification' => old_pw
    end

    def request_pw_reset
      action = AuthAction.new Cloud.instance
      action.type = 'PASSWORD_RESET'
      action.name = @email
      action.data = nil
      action.post
    end
  end
end

