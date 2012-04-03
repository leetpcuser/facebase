# Gems running inside
require 'rubygems'
require 'aws-sdk'
require 'eventmachine'
require 'work_queue'
require 'active_support'
require "em-http-request"
require 'koala'
require "redis"
require 'resque'
require 'resque_scheduler'
require 'resque/scheduler'

# Core libs
require 'thread'
require 'base64'
require 'json'
require 'singleton'

# Core requirements
require "facebase/engine"
require 'facebase/shard_management'
require 'facebase/principle_model'
require 'facebase/shard_initializer'
require 'facebase/sendgrid/smtp_api_header'
require 'facebase/mixpanel_client'
require 'facebase/redis/index'
require 'facebase/redis/lock'
require 'facebase/importer'
require 'facebase/email_template/template_values_sniffer'
require 'facebase/email_template/mock_email_service_provider'

# Printing utilities
require 'pp'

module Facebase

  # --------------------------------------------- Configuration

  configuration_attributes = [
    # Tracking info
    :tracker_host, :tracker_fall_back_site,
    # AWS Credentials
    :aws_access_key_id, :aws_secret_access_key, :aws_campaign_bucket,
    # Authentication for admin
    :username, :password,
    # Mixpanel
    :mixpanel_token,
    # Litmus
    :litmus_static_email,
    # Redis lock store
    :redis_lock_uri,
    # Redis resque store
    :redis_resque_uri,
    # Optional redis index for primary model
    :redis_index_uri,
    # Unsubscribe url
    :unsubscribe_url,
    # Configuration sql server
    :config_database_uri
  ]

  mattr_accessor *configuration_attributes


  # Allows the initializer to set the configuration
  def self.configure(&block)
    block.call(self)
  end

end
