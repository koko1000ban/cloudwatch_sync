


require 'aws-sdk'
require 'active_support/core_ext'

module CloudwatchSync
  class << self
    def configure(&block)
      CloudwatchSync::Client.configure(&block)
    end

    def sync(srv = nil)
      CloudwatchSync::Client.sync(srv)
    end

    def list
      CloudwatchSync::Client.list
    end
  end
end

$:.unshift File.expand_path('..', __FILE__)
require 'cloudwatch_sync/version'
require 'cloudwatch_sync/client'
require 'cloudwatch_sync/agents'
