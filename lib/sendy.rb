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

  class << self
    attr_accessor :app_host, :app_esp_name, :app_esp_password, :api_call
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
                                headers: { Authorization: last_auth_header })
    #rescue RestClient::Unauthorized
    #relogin
    #RestClient::Request.execute(method: method, url: url, payload: params,
    #                            headers: { Authorization: sendy_api.authorization })
  end

  def self.esp_login_params
    { esp_name: @app_esp_name, esp_password: @app_esp_password }
  end

  def relogin
    login
  end
end
