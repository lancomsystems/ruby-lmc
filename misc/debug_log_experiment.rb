require_relative 'lib/lmc.rb'
LMC::Cloud.debug=true
c = LMC::Cloud.new "cloud.lancom.de", 'foo', 'bar'
c.auth_for_accounts ['asdf']