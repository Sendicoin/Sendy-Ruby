# frozen_string_literal: true

require 'cgi'
require 'faraday'
require 'json'
require 'logger'
require 'openssl'
require 'rbconfig'
require 'securerandom'
require 'set'
require 'socket'
require 'uri'
require 'rest-client'

# Version
require 'sendy/version'

# API operations
require 'sendy/api_operations/create'
require 'sendy/api_operations/delete'
require 'sendy/api_operations/list'
require 'sendy/api_operations/request'
require 'sendy/api_operations/save'
require 'sendy/api_operations/count'

# API resource support classes
require 'sendy/util'
require 'sendy/sendy_object'
require 'sendy/list_object'
require 'sendy/api_resource'

# Named API resources
require 'sendy/campaign'
require 'sendy/event'
require 'sendy/subscriber'
require 'sendy/transaction'
require 'sendy/user'
require 'sendy/esp'

module Sendy
  class AuthenticationError < StandardError; end
  class DuplicateEvent < StandardError; end
  class InvalidParams < StandardError; end
  class InternalAPIError < StandardError; end
  class IncorrectTransaction < StandardError; end
  class InvalidRequestError < StandardError; end

  class << self
    attr_accessor :app_host, :app_esp_name, :app_esp_password, :user_api_token
  end

  def self.esp_login_params
    { esp_name: @app_esp_name, esp_password: @app_esp_password }
  end
end
