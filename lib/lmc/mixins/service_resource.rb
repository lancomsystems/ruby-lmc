# frozen_string_literal: true

module LMC
  module ServiceResource
    def self.included(klass)
      klass.class_exec do
        def initialize(cloud)
          @cloud = cloud
        end
      end
      klass.class_exec do
        def methodtest
          puts("cloud-service-#{service_name}")
        end

        # method that wraps attr_accessor to keep the defined attrs in a class instance var for serializing
        def self.resource_attrs(*attrs)
          @resource_attributes ||= []
          @resource_attributes.concat attrs
          attr_accessor(*attrs)
        end

        def self.resource_attributes
          @resource_attributes
        end
      end
    end

    def method_on_instance_of_class
      puts("cloud-service-#{service_name} #{inspect}, #{@cloud}")
    end

    def collection_path
      ["cloud-service-#{service_name}", collection_name]
    end

    def post
      @cloud.post collection_path, self
    end
  end
end

