# ruby-lmc

This gem provides access to select lmc functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lmc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lmc

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
### Running a single test file
    rake test TEST=test/file_with_tests.rb

### Running a single test
    rake test TESTOPTS="--name=test_foobar1"
### Tests against real LMC instances

#### credentials file
    email: testuser@foocorp.example
    password: Foobar1+
    lmc_url: https://my.lmc.example
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lancomsystems/ruby-lmc.
