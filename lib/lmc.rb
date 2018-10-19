require 'json'
require 'restclient'

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

Dir.glob(File.expand_path("../lmc/mixins/*.rb", __FILE__)).each do |file|
  require file
end

Dir.glob(File.expand_path("../lmc/*.rb", __FILE__)).each do |file|
  require file
end

["exceptions", "auth"].each do |folder|
  Dir.glob(File.expand_path("../lmc/#{folder}/*.rb", __FILE__)).each do |file|
    require file
  end
end

