# Metalogger

Inspired by Elixir's Logger.metadata and Go's contextual logger. Heavily inspired by Timber's work on a contextual logger for Ruby and ActiveSupport tagged logger.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metalogger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install metalogger

## Usage

```ruby
logger = Metalogger::Logger.new(STDOUT)

logger.with_meta(user_id: 127) do
  logger.info("payment created")
end
#> level=INFO message="payment created" meta.pid=559 meta.user_id=127 timestamp=2020-04-17T02:35:15+08:00

logger.info("payment created")
#> level=INFO message="payment created" meta.pid=559 timestamp=2020-04-17T02:35:15+08:00

logger.add_meta(user_id: 127)
logger.info("payment created")
#> level=INFO message="payment created" meta.pid=559 meta.user_id=127 timestamp=2020-04-17T02:35:15+08:00

logger.reset_meta
logger.info("payment created")
#> level=INFO message="payment created" meta.pid=559 timestamp=2020-04-17T02:35:15+08:00

logger.info(this: "is", a: "rich", message: "something")
#> a=rich level=INFO message=something meta.pid=559 this=is timestamp=2020-04-17T02:35:15+08:00
```

## Formatters

**LogfmtFormatter** *(default)*

```ruby
logger.formatter = Metalogger::LogfmtFormatter.new
#> level=info message="payment created" meta.pid=297 meta.user_id=127 timestamp=2020-04-17T02:27:59+08:00
```

**JSONFormatter**

```ruby
logger.formatter = Metalogger::JSONFormatter.new
#> {"level":"info","timestamp":"2020-04-17T02:29:42+08:00","message":"payment created","meta":{"pid":297,"user_id":127}}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/metalogger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/imranismail/metalogger/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the metalogger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/metalogger/blob/master/CODE_OF_CONDUCT.md).
