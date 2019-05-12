# frozen_string_literal: true

module LMC
  class AccountManager
    # @options
    # @global_options
    # @errors
    attr_reader :errors

    def initialize(options, global_options)
      @options = options
      @global_options = global_options
      @errors = []
    end

    # returns nil if invite did not work
    def invite(lmcen, distro, line, type, authority_name)
      lmcen.auth_for_accounts([distro['id']])
      line = line.strip.downcase
      begin
        account = Account.get(distro['id'])
        account_authorities = account.authorities
        # puts account_authorities.inspect if @global_options[:debug]
        if @global_options[:debug]
          account_authorities.each do |a|
            puts a['name']
            puts a.inspect
          end
        end
        authority = account_authorities.find { |auth| auth['name'] == authority_name }
        # puts "account authorities: #{account_authorities}" if @global_options[:debug]
        puts authority if @global_options[:debug]
        if !@options[:dry]
          # TODO: wenn der default authority nicht gibt geht das ding kaputt
          invited = lmcen.invite_user_to_account(line, distro['id'], type, [authority['id']])
          puts 'Invite response:' + invited.inspect if @global_options[:debug]
          puts 'Invited ' + invited['name'].to_s + " to account #{distro['name']}(#{invited.code})." if @global_options[:v]
          if invited.code != 200
            @errors << { :line => line, :result => invited.body }
            return nil
          end
        else
          invited = { 'name' => line }
        end

        invite_url = lmcen.build_url('#', 'register', Base64.encode64(invited['name']))
        if @options['show-csv']
          puts "\n" + invited['name'] + ', ' + invite_url
        end
        if @options['send-mail'] && invited
          mailbody = <<END
  Hallo,
  auf #{lmcen.cloud_host} wurde eine Einladung zu dem Account #{distro['name']} für den Nutzer #{invited['name']} erstellt.
  
  Falls der Account noch nicht existiert, kann dieser Link zur Registrierung genutzt werden:
END
          mail = Mail.new do
            from 'Philipp Erbelding <philipp.erbelding@lancom.de>'
            to invited['name']
            subject 'Einladung auf ' + lmcen.cloud_host
            body mailbody + invite_url
          end

          puts invite_url
          if !@options[:dry]
            puts 'sending mail to ' + invited['name']
            mail.delivery_method :smtp, address: 'lcs-mail'
            mail.deliver
          else
            puts '[DRY RUN] would send mail to ' + invited['name']
          end
          puts mail.to_s if @global_options[:v]
        end

      rescue RestClient::ExceptionWithResponse => e
        puts e.to_s
        puts invited.inspect
        resp = JSON.parse(e.response)
        puts resp.inspect
        puts resp['message']
      end
      true
    end
  end
end
