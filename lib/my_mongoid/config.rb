require 'moped'
require 'singleton'

module MyMongoid
  # This module defines all the configuration options for Mongoid
  module Config
    def models
      @models ||= []
    end

    def register_model(klass)
      @models.push(klass) unless models.include?(klass)
    end

    def configuration
      Configuration.instance
    end

    def configure(&block)
      # this method should receive a block
      # the Configuration singleton would be set with options
      yield(configuration)
    end

    def session
      host = configuration.host
      host = [host] unless host.is_a? Array
      database = configuration.database
      raise UnconfiguredDatabaseError if host.nil? || database.nil?
      @session ||= Moped::Session.new(host, :database => database)
    end

  end

  extend MyMongoid::Config

  class Configuration
    include Singleton
    attr_accessor :host, :database
  end
end
