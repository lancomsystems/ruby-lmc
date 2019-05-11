# frozen_string_literal: true

module LMC
  class DeviceDSCUi
    def initialize(device)
      @device = device
      @body = @device.cloud.get(url_dscui).body

      @version = Version.new @body['versions']
    end

    def url_dscui
      ['cloud-service-config', 'configdevice', 'accounts', @device.account.id, 'devices',
       @device.id, 'dscui']
    end

    def item_by_id_map
      item_map = {}
      item_map.default = Item.dummy
      @version.items.inject(item_map) do |acc, item|
        acc.store(item.id, item)
        acc
      end
      return item_map
    end

    class Version
      attr_reader :version_string, :sections

      def initialize(v_hash)
        keys = v_hash.keys
        raise('More than one version key contained in dscui.') if keys.length > 1
        @version_string = keys.first
        @sections = v_hash[@version_string].map {|section_wrapper| Section.new section_wrapper}

      end

      def items
        @sections.map {
            |s| s.groups.map {
              |g| g.items
          }
        }.flatten.compact
      end
    end

    class Section
      attr_reader :names, :groups

      def initialize(section_wrapper)
        section = section_wrapper['section']
        @names = section['name']
        members = section['members']
        @groups = members.map {|group_wrapper|
          Group.new group_wrapper unless group_wrapper['group'].nil?
        }.compact

      end
    end

    class Group
      attr_reader :names, :items

      def initialize(group_wrapper)
        group = group_wrapper['group']
        @names = group['name']
        @items = group['members'].map {|item_wrapper| Item.new item_wrapper}
      end
    end

    class Item
      attr_reader :type, :id

      def self.dummy
        Item.new({'dummy' => {'description' => []}})
      end

      def initialize(item_wrapper)
        keys = item_wrapper.keys
        raise('More than one key contained in item wrapper') if keys.length > 1
        @type = keys.first
        item = item_wrapper[@type]
        @id = item['id']
        @descriptions = []
        @descriptions << item['description']
      end

      def description
        @descriptions.join(',')
      end
    end
  end
end