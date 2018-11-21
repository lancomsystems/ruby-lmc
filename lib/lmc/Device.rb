module LMC
  class Device
    attr_reader :id, :name, :model, :serial, :heartbeatstate

    def initialize(data)
      @cloud = Cloud.instance
      @id = data['id']
      @comment = data['comment']
      @name = data['status']['name']
      @serial = data['status']['serial']
      @model = data['status']['model']
      @heartbeatstate = data['status']['heartbeatState']
      @status = data['status']
      @account = data['account']
    end

    def get_config_for_account(account)
      response = @cloud.get ["cloud-service-config", "configbuilder", "accounts", account.id, "devices", @id, "ui"]
      JSON.parse(JSON.generate(response.body.to_h)) #terrible hack to get it to work for now. needs way to get more raw body_object from Response
    end

    def set_config_for_account(config, account)
      @cloud.put ["cloud-service-config", "configbuilder", "accounts", account.id, "devices", @id, "ui"], config
    end

    def get_monitor_widgets(widget_item_ids)
      @cloud.get ["cloud-service-monitoring", @account.id, "devices", @id, "monitordata"], { :widgetItemIds => widget_item_ids.join(",") }
    end

    def self.get_for_account(account)
      cloud = Cloud.instance
      cloud.auth_for_accounts [account.id]
      list = cloud.get ["cloud-service-devices", "accounts", account.id, "devices"]
      if list.code != 200
        puts "Error getting devices: #{list.body.message}"
        exit 1
      end
      devices = list.map do |data|
        data["account"] = account
        LMC::Device.new(data)
      end
      return devices
    end

    def self.get_for_account_id(account_id)
      self.get_for_account Account.get(account_id)
    end

    def config_state
      @config_state ||= get_config_state
    end

    def logs
      # https://lmctest/#/project/6392b234-b11c-498a-a077-a5f5b23c54a0/devices/compact/eaafa152-62cf-48a1-be65-b222886daa6d/logging
      #cloud = Cloud.instance
      ##cloud.auth_for_accounts [id]
      #cloud.get ["cloud-service-logging", "accounts", id, "logs?lang=DE"]
      raise "device logs not supported"
    end

    private

    def get_config_state
      reply = @cloud.get ["cloud-service-config", "configdevice", "accounts", @account.id, "state"], { "deviceIds" => @id }
      if reply.code == 200
        #            binding.pry
        DeviceConfigState.new reply.body[@id]
      end
    end


  end

end
