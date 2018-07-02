# frozen_string_literal: true

require "cgi"
require "faraday"
require "json"
require "logger"
require "openssl"
require "rbconfig"
require "securerandom"
require "set"
require "socket"
require "uri"
require "rest-client"

# Version
require "sendy/version"

# API operations
require "sendy/sendy_api"
require "sendy/campaigns"
require "sendy/subscribers"
require "sendy/events"
require "sendy/transactions"
require "sendy/users"

module Sendy
  @app_info = nil
end
