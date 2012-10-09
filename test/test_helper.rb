ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'
require 'test/unit'

require 'action_mailer'
ActionMailer::Base.delivery_method = :test

require 'sidekiq'
require 'sidekiq/testing'

require 'sidekiq_mailer'