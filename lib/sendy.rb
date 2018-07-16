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
require "sendy/api"
require "sendy/campaign"
require "sendy/subscriber"
require "sendy/event"
require "sendy/transaction"
require "sendy/user"

module Sendy
  @app_info = nil

  class DuplicateEvent < StandardError; end
  class InvalidParams < StandardError; end
  class InternalAPIError < StandardError; end
  class IncorrectTransaction < StandardError; end
  class InvalidRequestError < StandardError; end

  def create_user_url
    "#{Sendy.app_host}/auth/signup"
  end

  def find_user_url
    "#{Sendy.app_host}/auth/find_user"
  end

  def add_tokens_url
    "#{Sendy.app_host}/api/add_tokens_to_user"
  end

  class << self
    attr_accessor :app_host, :app_esp_name, :app_esp_password
  end

  def api_call(method, url, params = nil)
    response = JSON.parse(api_request(method, url, params))
  rescue RestClient::NotAcceptable => e
    puts e.response
    raise InvalidParams.new(e.response.to_s)
  rescue RestClient::UnprocessableEntity => e
    message = e.response.to_s
  rescue RestClient::InternalServerError => e
    raise InternalAPIError.new
  end

  def api_request(method, url, params = nil)
    RestClient::Request.execute(method: method, url: url, payload: params,
                                headers: { Authorization: "token #{api_token}" })
  end

  def self.esp_login_params
    { esp_name: @app_esp_name, esp_password: @app_esp_password }
  end
end
