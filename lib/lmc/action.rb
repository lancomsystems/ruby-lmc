module LMC
    class AuthAction
        class AuthActionPrincipal
            def initialize(data)
                @name = data['name']
                @id = data['id']
                @state = data['state']
            end
        end
        # {"type":"ACCOUNT_INVITE","loginRequired":true,"principal":{"name":"apireverse@copythat.de","id":"5a3f4967-888e-4006-aa4b-2ee6c79d8475","state":"PENDING"},"data":{"membershipId":"a8aff536-2ea9-49fa-aef7-8db4e05c80b1","inviterId":"f4ecc794-e64a-40a4-b39d-90c114024ec8"}}
        def initialize(data)
            @type = data['type']
            @loginRequired = data['loginRequired']
            @principal = AuthActionPrincipal.new(data['principal'])
            @membershipId = data['data']['membershipId']
        end
        def self.get(id)
        #https://beta.cloud.lancom.de/cloud-service-auth/actions/2615899fdb933e99fbdaefa2e57144c5132b022216f7
            cloud = Cloud.instance
            result = cloud.get ["cloud-service-auth", "actions", ]
            return AuthAction.new(result.body)
        end
    end
end
