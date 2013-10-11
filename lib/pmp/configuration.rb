# -*- encoding: utf-8 -*-

require 'active_support/concern'

module PMP
  module Configuration 

    extend ActiveSupport::Concern

    VALID_OPTIONS_KEYS = [
      :client_id,
      :client_secret,
      :oauth_token,
      :adapter,
      :endpoint,
      :user_agent,
      :debug
    ].freeze

    # this you need to get from pmp, not covered by this
    DEFAULT_CLIENT_ID     = nil
    DEFAULT_CLIENT_SECRET = nil
    
    # Adapters are whatever Faraday supports - I like excon alot, so I'm defaulting it
    DEFAULT_ADAPTER       = :excon
    
    # The api endpoint for YQL
    DEFAULT_ENDPOINT      = 'https://api.pmp.io/'.freeze
    
    # The value sent in the http header for 'User-Agent' if none is set
    DEFAULT_USER_AGENT    = "PMP-SDK Ruby Gem #{PMP::VERSION}".freeze
    
    # debug is defaulted to the ENV['DEBUG'], see below

    attr_accessor *VALID_OPTIONS_KEYS

    included do

      attr_accessor :options

      VALID_OPTIONS_KEYS.each do |key|
        define_method "#{key}=" do |arg|
          self.instance_variable_set("@#{key}", arg)
          self.options.merge!({:"#{key}" => arg})
        end
      end

    end

    def apply_configuration(opts={})
      reset! unless @options
      self.options = options.merge(opts)
      VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    # Convenience method to allow for global setting of configuration options
    def configure
      yield self
    end

    # Reset configuration options to their defaults
    def reset!
      @options = {}
      self.client_id     = DEFAULT_CLIENT_ID
      self.client_secret = DEFAULT_CLIENT_SECRET
      self.adapter       = DEFAULT_ADAPTER
      self.endpoint      = DEFAULT_ENDPOINT
      self.user_agent    = DEFAULT_USER_AGENT
      self.debug         = ENV['DEBUG']
      self
    end

    def options
      options = {}
      VALID_OPTIONS_KEYS.each { |k| options[k] = send(k) }
      options
    end

    module ClassMethods

      def keys
        VALID_OPTIONS_KEYS
      end      

    end

  end
end