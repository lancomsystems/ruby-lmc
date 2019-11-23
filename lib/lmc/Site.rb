# frozen_string_literal: true

module LMC
  class Site
    attr_accessor :name
    attr_reader :id, :account, :subnet_group_id

    def initialize(data, account)
      @cloud = account.cloud
      @cloud.auth_for_account account if account
      @account = account
      data = @cloud.get ['cloud-service-devices', 'accounts', @account.id, 'sites', data] if data.is_a? UUID

      @id = data['id']
      @name = data['name']
      @subnet_group_id = data['subnetGroupId']

    end

    def to_s
      "#{@name}"
    end

    def configstates
      response = @cloud.get ['cloud-service-config', 'configsubnetgroup', 'accounts', @account.id, 'subnetgroups', @subnet_group_id, 'updatestates']
      LMC::Configstates.new response.body
    end
  end
end
