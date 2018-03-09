require 'bundler'
require 'lmc/version'
require 'lmc/Cloud'

Dir.glob(File.expand_path("../lmc/*.rb", __FILE__)).each do |file|
  require file
end

Dir.glob(File.expand_path("../lmc/exceptions/*.rb", __FILE__)).each do |file|
  require file
end

module LMC
  def self.useful
    puts 'useful'
    return true
  end
end
