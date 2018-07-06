module LMC
  class Site
    attr_accessor :name
    attr_reader :id, :account

    def initialize(data, account)
      @cloud = Cloud.instance
      @id = data["id"]
      @name = data["name"]
      @subnet_group_id = data["subnetGroupId"]
      @account = account

      if @account
        @cloud.auth_for_account @account
      end
    end

    def to_s
      "#{@name}"
    end

    def account=(account)
      if @account == nil
        @account = account
        return true
      else
        raise "Cannot replace account for site"
      end
    end

    def configstates
      response = @cloud.get ["cloud-service-config", "configsubnetgroup", "accounts", @account.id, "subnetgroups", @subnet_group_id, "updatestates"]
      states = LMC::Configstates.new response.body
      return states
    end
  end

end
