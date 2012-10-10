# Sidekiq::Mailer

Sidekiq::Mailer adds to your ActionMailer classes the ability to send mails asynchronously.

## Usage

If you want to make a specific mailer to work asynchronously just include Sidekiq::Mailer module:

    class MyMailer < ActionMailer::Base
      include Sidekiq::Mailer

      def welcome(to)
        ...
      end
    end

Now every deliver you make with MyMailer will be asynchronous.

    # Queues the mail to be sent asynchronously by sidekiq
    MyMailer.welcome('your@email.com').deliver

The default queue used by Sidekiq::Mailer is 'mailer'. So, in order to send mails with sidekiq you need to start a worker using:

    sidekiq -q mailer

If you want to skip sidekiq you should use the 'deliver!' method:

    # Mail will skip sidekiq and will be sent synchronously
    MyMailer.welcome('your@email.com').deliver!

By default Sidekiq::Mailer will retry to send an email if it failed. But you can [override sidekiq options](https://github.com/andersondias/sidekiq_mailer/wiki/Overriding-sidekiq-options) in your mailer.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_mailer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_mailer

## Testing

Delayed e-mails is an awesome thing in production environments, but for e-mail specs/tests in testing environments it can be a mess causing specs/tests to fail because the e-mail haven't been sent directly. Therefore you can configure what environments that should be excluded like so:

    # config/initializers/sidekiq_mailer.rb
    Sidekiq::Mailer.excluded_environments = [:test, :cucumber]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
