# frozen_string_literal: true

module LMC
  class Device
    attr_reader :id, :name, :model, :serial, :heartbeatstate, :cloud, :account

    def initialize(data)
      @id = data['id']
      @comment = data['comment']
      @name = data['status']['name']
      @serial = data['status']['serial']
      @model = data['status']['model']
      @heartbeatstate = data['status']['heartbeatState']
      @status = data['status']
      @account = data['account']
      @cloud = @account.cloud
      @cloud ||= Cloud.instance
    end

    def set_config_for_account(config, account)
      @cloud.put ['cloud-service-config', 'configbuilder', 'accounts', account.id, 'devices', @id, 'ui'], config
    end

    def get_monitor_widgets(widget_item_ids)
      @cloud.get ['cloud-service-monitoring', @account.id, 'devices', @id, 'monitordata'], { :widgetItemIds => widget_item_ids.join(',') }
    end

    def self.get_for_account(account)
      cloud = Cloud.instance
      cloud.auth_for_accounts [account.id]
      list = cloud.get ['cloud-service-devices', 'accounts', account.id, 'devices']
      if list.code != 200
        puts "Error getting devices: #{list.body.message}"
        exit 1
      end
      devices = list.map do |data|
        data['account'] = account
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

    def config
      LMC::DeviceConfig.new(@cloud, @account, self)
    end

    def record name
      MonitoringRecord.new(@cloud, @account, self, name)
    end

    def monitor_record_group
      'DEVICE'
    end

    private

    def get_config_state
      reply = @cloud.get ['cloud-service-config', 'configdevice', 'accounts', @account.id, 'state'], { 'deviceIds' => @id }
      if reply.code == 200
        #            binding.pry
        DeviceConfigState.new reply.body[@id]
      end
    end

  end

end
