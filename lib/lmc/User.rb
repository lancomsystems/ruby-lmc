module LMC
  class User
    class Contact < OpenStruct

    end
    class TermOfUse
        attr_accessor :name, :acceptance

        def self.getAll
            result = Cloud.instance.get ['cloud-service-auth', 'terms-of-use']
            result.inspect
            "foo"
        end
    end

    #todo: look into hiding password
    attr_reader :email
    attr_accessor :contact, :termsOfUse

    def initialize(data)
      @email = data["email"]
      @id = data["id"]
      @password = data["password"]
      @contact = Contact.new data['contact']

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

    def register(action_id)
        cloud = Cloud.instance
        action = AuthAction.get(action_id)
        # curl 'https://beta.cloud.lancom.de/cloud-service-auth/terms-of-use?language=de' 
        # POST https://beta.cloud.lancom.de/cloud-service-auth/users
        # curl 'https://beta.cloud.lancom.de/cloud-service-auth/users' --data-binary $'{"email":"apireverse@","token":"2615899fdb933e99fb155216f7","contact":{"gender":"MALE","firstName":"vor","lastName":"nach"},"password":"","passwordRepeat":"","termsOfUse":[{"name":"general","acceptance":"2017-10-10"}]}'
    end
  end
  
end
