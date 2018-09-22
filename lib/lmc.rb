require 'json'
require 'restclient'

Dir.glob(File.expand_path("../lmc/*.rb", __FILE__)).each do |file|
  require file
end

Dir.glob(File.expand_path("../lmc/**/*.rb", __FILE__)).each do |file|
  require file
end

module LMC
  SERVICELIST = ['cloud-service-auth',
                 'cloud-service-devices',
                 'cloud-service-monitoring',
                 'cloud-service-config',
                 'cloud-service-licenses']

  def self.useful
    return true
  end
end
