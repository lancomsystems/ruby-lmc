module LMC
  class AuthAction
    include LMC::ServiceResource
    include LMC::JSONAble
    resource_attrs :name, :type, :data
    # action types
    ACCOUNT_INVITE = 'ACCOUNT_INVITE'
    PASSWORD_RESET = 'PASSWORD_RESET'
    ACCOUNT_DELETE = 'ACCOUNT_DELETE'
    USER_PROFILE_DELETE = 'USER_PROFILE_DELETE'

    def service_name
      'auth'
    end
    def collection_name
      'actions'
    end

  end
end