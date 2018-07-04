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

SENDY_HOST = @api_base
LOGIN_URL = "#{SENDY_HOST}/auth/login".freeze
SUBSCRIBERS_URL = "#{SENDY_HOST}/api/subscribers".freeze
EVENTS_URL = "#{SENDY_HOST}/api/events".freeze
CAMPAIGNS_URL = "#{SENDY_HOST}/api/campaigns".freeze
CAMPAIGNS_COUNT_URL = "#{SENDY_HOST}/api/campaigns/count.json".freeze
SUBSCRIBERS_COUNT_URL = "#{SENDY_HOST}/api/subscribers/count.json".freeze
EVENTS_COUNT_URL = "#{SENDY_HOST}/api/events/count.json".freeze
TRANSACTIONS_URL = "#{SENDY_HOST}/api/transactions".freeze
CREATE_USER_URL = "#{SENDY_HOST}/auth/signup"
FIND_USER_URL = "#{SENDY_HOST}/auth/find_user"
ADD_TOKENS_URL = "#{SENDY_HOST}/api/add_tokens_to_user"

module Sendy
  @app_info = nil
end
