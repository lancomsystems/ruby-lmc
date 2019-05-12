# frozen_string_literal: true

module LMC
  class MonitoringRecord
    # https://beta.cloud.lancom.de/cloud-service-monitoring/accounts/316f5f14-ff6c-4fd4-a49a-d28a6b3ba26c/records/uptime?count=144&
    # group=DEVICE&groupId=8b2a3fef-2f7b-444c-86e7-1cf1b509e951&name=device&period=MINUTE10&relative=0&type=scalar
    def record_url
      ['cloud-service-monitoring', 'accounts', @account.id, 'records', @record_name]
    end

    def initialize(cloud, account, grouping, record_name)
      @cloud = cloud
      @account = account
      @record_name = record_name
      @grouping = grouping
    end

    def scalar(name, count, period)
      fetch_data name, count, period, 'scalar'
    end

    def row(name, count, period)
      fetch_data name, count, period, 'row'
    end

    private

    def fetch_data(name, count, period, type, relative = 0)
      r = @cloud.get record_url, count: count, group: @grouping.monitor_record_group, groupId: @grouping.id, name: name, period: period, relative: relative, type: type
      r.body
    end
  end
end
