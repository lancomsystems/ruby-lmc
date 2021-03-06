# frozen_string_literal: true

require_relative 'account_manager.rb'
require_relative 'entity'
module LMC
  class Account < Entity
    ROOT_ACCOUNT_UUID = '9ec458c2-d05f-3004-96f0-ebe73fa20de8'
    attr_accessor :name
    attr_reader :id, :state, :type, :identifier, :cloud

    def self.get(id)
      cloud = Cloud.instance
      result = cloud.get ['cloud-service-auth', 'accounts', id.to_s]
      Account.new(cloud, result.body)
    end

    def self.get_by_uuid(uuid)
      raise 'Missing argument' if uuid.nil?
      get uuid
    end

    def self.get_by_name(name, type = nil)
      raise 'Missing argument' if name.nil?
      accounts = Cloud.instance.get_accounts_objects.select do |a|
        (name.nil? || a.name == name) && (type.nil? || a.type == type)
      end
      if accounts.length == 1
        accounts[0]
      elsif accounts.length == 0
        raise 'Did not find account'
      else
        raise 'Account name not unique'
      end
    end

    def initialize(cloud, data)
      @cloud = cloud
      apply_data(data)
    end

    # returns itself, allows chaining
    def save
      response = if @id.nil?
                   @cloud.auth_for_accounts [@parent]
                   @cloud.post ['cloud-service-auth', 'accounts'], self
                 else
                   @cloud.post path, self
                 end
      apply_data(response.body)
      self
    end

    def delete!
      if @id != nil
        @cloud.auth_for_accounts [@id]
        delete_action = AuthAction.new @cloud
        delete_action.type = AuthAction::ACCOUNT_DELETE
        delete_action.name = Cloud.user
        delete_action.data = { 'password' => Cloud.password,
                              'accountId' => @id }
        delete_action.post
        @id = nil
        true
      end
    end

    def exists?
      # noch ungelöst: woran mache ich fest, ob das objekt in der DB schon da ist.
      # Bleibt wohl nix außer manuell auf @id != nil zu checken.
      @id != nil
    end

    def members
      ids = Cloud.instance.get ['cloud-service-auth', 'accounts', @id, 'members'], 'select' => 'id'
      puts ids.inspect if Cloud.debug
      # these are not actual membership objects
      memberships = ids.map do |member_id|
        response = Cloud.instance.get ['cloud-service-auth', 'accounts', @id, 'members', member_id]
        memberships = response.body
        puts memberships.inspect if Cloud.debug
        memberships
      end
      memberships
    end

    def find_member_by_name(name)
      if name.nil?
        raise 'No member name given'
      end
      member = members.find { |m| m.name == name }
      unless member
        raise "Member named #{name} not found in account #{self}"
      end
      member
    end

    #--
    # def update_member(principal_id, data)
    #  response = @cloud.post ["cloud-service-auth", "accounts", id, 'members', principal_id], data
    #  return response
    # end
    #++

    def remove_membership(member_id)
      @cloud.delete ['cloud-service-auth', 'accounts', id, 'members', member_id]
    end

    def remove_membership_self
      @cloud.delete ['cloud-service-auth', 'accounts', id, 'members', 'self']
    end

    def authority(authority_id)
      response = @cloud.get(
          ['cloud-service-auth', 'accounts', id, 'authorities', authority_id]
      )
      Authority.new(response, self)
    end

    def authorities
      response = @cloud.get ['cloud-service-auth', 'accounts', id, 'authorities']
      raise 'Unable to get authorities' unless response.code == 200
      authorities = response.body.map do |r|
        Authority.new r, self
      end
      authorities
    end

    def children
      @cloud.auth_for_accounts([ROOT_ACCOUNT_UUID])
      # Projects can not have children, return empty map immediately as optimization
      if type != 'PROJECT'
        response = @cloud.get ['cloud-service-auth', 'accounts', id, 'children']
        response.map { |child| Account.new @cloud, child }
      else
        []
      end
    end

    # This can only show the most recent page of logs so far
    def logs
      cloud = Cloud.instance
      cloud.auth_for_accounts [id]
      cloud.get(['cloud-service-logging', 'accounts', id, 'logs', 'paginated?lang=DE']).body.logs
    end

    def sites
      # private clouds can not have sites
      return [] if @type == 'PRIVATE_CLOUD'
      @cloud.auth_for_accounts([id])
      response = @cloud.get ['cloud-service-devices', 'accounts', id, 'sites'], :select => :id
      response.body.map { |data|
        Site.new(UUID.new(data), self)
      }
    end

    def devices
      Device.get_for_account self
    end

    def config_updatestates
      @cloud.auth_for_accounts([id])
      response = @cloud.get ['cloud-service-config', 'configdevice', 'accounts', id, 'updatestates']
      LMC::Configstates.new response.body
    end

    def to_json(*a)
      {
          'name' => @name,
          'state' => @state,
          'type' => @type,
          'parent' => @parent
      }.to_json(*a)
    end

    def to_s
      "#{name}"
    end

    def summary
      "\"#{@name}\" (#{@type}) ID: #{@id}"
    end

    private

    ## should be put into entity or such
    def path
      ['cloud-service-auth', 'accounts', @id].join('/')
    end

    def apply_data(data)
      @id = data['id']
      @parent = data['parent']
      @name = data['name']
      @state = data['state']
      @type = data['type']
      @identifier = data['identifier']
    end
  end
end

