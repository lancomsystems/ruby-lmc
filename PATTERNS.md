# Should establish
## URLs in ressource classes
    def url_configbuilder
      ['cloud-service-config', 'configbuilder', 'accounts',
       @account.id, 'devices', @device.id, 'ui']
    end

## Embedding the Cloud object in ressources
* first parameter in initalizer
* saved in @cloud instance var

# Unsolved, bad
* Cloud http methods (get, etc.) return response object. 99% of the time, have to call .body on it