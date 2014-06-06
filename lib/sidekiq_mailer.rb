require 'sidekiq_mailer/version'
require 'sidekiq_mailer/worker'
require 'sidekiq_mailer/proxy'

module Sidekiq
  module Mailer
    @@excluded_environments = nil

    def self.excluded_environments=(envs)
      @@excluded_environments = [*envs].map { |e| e && e.to_sym }
    end

    def self.excluded_environments
      @@excluded_environments ||= []
    end

    def self.current_env
      if defined?(Rails)
        ::Rails.env
      else
        ENV['RAILS_ENV'].to_s
      end
    end

    def self.excludes_current_environment?
      !ActionMailer::Base.perform_deliveries || (excluded_environments && excluded_environments.include?(current_env.to_sym))
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute :sidekiq_options_hash
    end

    module ClassMethods
      ##
      # Allows customization for this type of Worker.
      # Legal options:
      #
      #   :queue - use a named queue for this Worker, default 'default'
      #   :retry - enable the RetryJobs middleware for this Worker, default *true*
      #   :timeout - timeout the perform method after N seconds, default *nil*
      #   :backtrace - whether to save any error backtrace in the retry payload to display in web UI,
      #      can be true, false or an integer number of lines to save, default *false*
      def sidekiq_options(opts={})
        self.sidekiq_options_hash = get_sidekiq_options.merge(stringify_keys(opts || {}))
      end

      DEFAULT_OPTIONS = { 'retry' => true, 'queue' => 'mailer' }

      def get_sidekiq_options # :nodoc:
        self.sidekiq_options_hash ||= DEFAULT_OPTIONS
      end

      def stringify_keys(hash) # :nodoc:
        hash.keys.each do |key|
          hash[key.to_s] = hash.delete(key)
        end
        hash
      end

      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          Sidekiq::Mailer::Proxy.new(self, method_name, *args)
        else
          super
        end
      end
    end
  end
end
