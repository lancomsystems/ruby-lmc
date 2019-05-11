# Should establish
## URLs in ressource classes
Add methods to build urls

    def url_configbuilder
      ['cloud-service-config', 'configbuilder', 'accounts',
       @account.id, 'devices', @device.id, 'ui']
    end

Not decided yet if private or public

## Parameter ordering for initialize methods

Library/API objects ordered from least to most specific.
Object specific data hashes go last.

### Embedding the Cloud object in ressources
* First parameter in initalizer
* Saved in @cloud instance var
* Should be exposed via getter (attr_reader)

It' is also okay to use Cloud object from parent object if a reasonable one is passed.


# Unsolved, bad
* Cloud http methods (get, etc.) return response object. 99% of the time, have to call .body on it