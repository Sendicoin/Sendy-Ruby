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
require "sendy/campaigns"
require "sendy/subscribers"
require "sendy/events"
require "sendy/transactions"
require "sendy/users"

module Sendy
  @app_info = nil

  class Sendy

    SENDY_HOST = 'localhost:3000'
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

    class DuplicateEvent < StandardError; end
    class InvalidParams < StandardError; end
    class InternalAPIError < StandardError; end
    class IncorrectTransaction < StandardError; end

    attr_accessor :email, :password, :esp_id, :authorization

    def initialize(esp_id, email, password, authorization = nil)
      @esp_id = esp_id
      @email = email
      @password = password
      @authorization = authorization
    end

    def login
      params = { esp_id: esp_id, email: email, password: password }
      @authorization = RestClient.post(LOGIN_URL, params).body
    end

    private

    def api_call(method, url, params = nil)
      response = JSON.parse(api_request(method, url, params))
    rescue RestClient::NotAcceptable => e
      puts e.response
      raise InvalidParams.new(e.response.to_s)
    rescue RestClient::UnprocessableEntity => e
      message = e.response.to_s
      case
      when message.match('Duplicate event')
        raise DuplicateEvent.new(message)
      else
        raise e
      end
    rescue RestClient::InternalServerError => e
      raise InternalAPIError.new
    end

    def api_request(method, url, params = nil)
      RestClient::Request.execute(method: method, url: url, payload: params,
                                  headers: { Authorization: authorization })
    rescue RestClient::Unauthorized
      relogin
      RestClient::Request.execute(method: method, url: url, payload: params,
                                  headers: { Authorization: authorization })
    end

    def relogin
      login
    end
  end
end
