# frozen_string_literal: true
module LMC
  class Preferences
    def initialize(cloud:, section:)
      @cloud = cloud
      @section = section
    end

    def get(path)
      response = @cloud.get build_url, { path: path }
      response.body
    end

    def put(path, payload)
      @cloud.put build_url, payload, { path: path }
    end

    private
    def build_url
      ['cloud-service-preferences'] + @section
    end
  end
end

