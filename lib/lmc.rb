# frozen_string_literal: true

require 'json'
require 'restclient'

module LMC
  SERVICELIST = ['cloud-service-auth',
                 'cloud-service-backstage',
                 'cloud-service-config',
                 'cloud-service-devices',
                 'cloud-service-devicetunnel',
                 'cloud-service-dyndns',
                 'cloud-service-fields',
                 'cloud-service-geolocation',
                 'cloud-service-hotspot',
                 'cloud-service-jobs',
                 'cloud-service-monitoring',
                 'cloud-service-messaging',
                 'cloud-service-notification',
                 'cloud-service-licenses',
                 'cloud-service-logging',
                 'cloud-service-preferences',
                 'cloud-service-uf-translator'
  ]

  def self.useful
    true
  end
end

Dir.glob(File.expand_path('../lmc/mixins/*.rb', __FILE__)).each do |file|
  require file
end

Dir.glob(File.expand_path('../lmc/*.rb', __FILE__)).each do |file|
  require file
end

['exceptions', 'auth', 'config', 'monitoring', 'preferences'].each do |folder|
  Dir.glob(File.expand_path("../lmc/#{folder}/*.rb", __FILE__)).each do |file|
    require file
  end
end

