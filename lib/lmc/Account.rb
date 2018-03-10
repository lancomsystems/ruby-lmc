require_relative 'account_manager.rb'
class LMC::LMCAccount
  attr_accessor :name
  attr_reader :id, :state, :type

  def [] key
    self.send(key)
  end

  def self.get(id)
    cloud = Cloud.instance
    result = cloud.get ["cloud-service-auth", "accounts", id]
    return LMCAccount.new(result)
  end

  def initialize(data)
    @cloud = LMC::Cloud.instance
    @id = data["id"]
    @parent = data["parent"]
    @name = data["name"]
    @state = data["state"]
    @type = data["type"]
  end

  def save
    if @id.nil?
      @cloud.auth_for_accounts [@parent]
      @cloud.post ["cloud-service-auth", "accounts"], self
    else
      @cloud.post path, self
    end
  end

  def delete
    if !@id.nil?
      @cloud.auth_for_accounts [@id]
      deleted = @cloud.delete ["cloud-service-auth", "accounts", @id]
      if deleted.code != 200
        raise "unable to delete account: #{deleted.body.message}"
      end
      return true
    end
  end

  def exists?
    # noch ungelöst: woran mache ich fest, ob das objekt in der DB schon da ist.
    # Bleibt wohl nix außer manuell auf @id != nil zu checken.
    LMCAccount.get(@id)
  end

  def members
    ids = Cloud.instance.get ["cloud-service-auth", "accounts", @id, 'members'], {"select" => "id"}
    puts ids.inspect if Cloud.debug
    principals = ids.map do |principal_id|
      response = Cloud.instance.get ["cloud-service-auth", "accounts", @id, 'members', principal_id]
      if response.code == 200
        principal = response.body
      else
        loggerr.error "ERROR: #{response.code} #{response.body.message}"
        principal = nil
      end
      puts principal.inspect if Cloud.debug
      principal
    end
    return principals
  end

  def update_member(principal_id, data)
    response = @cloud.post ["cloud-service-auth", "accounts", id, 'members', principal_id], data
    return response
  end

  def remove_membership(member_id)
    response = @cloud.delete ["cloud-service-auth", "accounts", id, "members", member_id]
  end

  def remove_membership_self
    response = @cloud.delete ["cloud-service-auth", "accounts", id, "members", "self"]
  end

  def children
    response = @cloud.get ["cloud-service-auth", "accounts", id, "children"], {"parent.id" => id}
    response.body
  end

  def children_for_account_id(accountid)
    response = @cloud.get ["cloud-service-auth", "accounts", id, "children"], {"parent.id" => accountid}
  end

  def authorities
    response = @cloud.get ["cloud-service-auth", "accounts", id, 'authorities']
    if response.code == 200
      return response.body
    else
      raise "Unable to get authorities"
    end
  end

  def logs
    # https://lmctest/cloud-service-logging/accounts/6392b234-b11c-498a-a077-a5f5b23c54a0/logs?lang=DE
    cloud = Cloud.instance
    cloud.auth_for_accounts [id]
    cloud.get ["cloud-service-logging", "accounts", id, "logs?lang=DE"]
  end

  def sites
    @cloud.auth_for_accounts([id])
    response = @cloud.get ["cloud-service-devices", "accounts", id, "sites"]
    if response.code == 200
      return response.body.map {|data|
        LMCSite.new(data, self)
      }
    elsif response.code == 404
      return []
    end
  end

  def config_updatestates
    @cloud.auth_for_accounts([id])
    response = @cloud.get ["cloud-service-config", "configdevice", "accounts", id, "updatestates"]
    return LMCConfigstates.new response.body
  end

  def to_json(*a)
    {
        "name" => @name,
        "state" => @state,
        "type" => @type,
        "parent" => @parent
    }.to_json(*a)
  end

  def to_s
    "#{name}"
  end

  private
  def path
    ["cloud-service-auth", "accounts", @id].join("/")
  end

end
