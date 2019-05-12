# frozen_string_literal: true

module LMC
  class AuthAction
    include LMC::ServiceResource
    resource_attrs :name, :type, :data
    include LMC::JSONAble
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
