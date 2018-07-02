module Sendy
  class SendyApi
    class DuplicateEvent < StandardError; end
    class InvalidParams < StandardError; end
    class InternalAPIError < StandardError; end
    class IncorrectTransaction < StandardError; end

    attr_accessor :email, :password, :esp_id, :authorization
    SENDY_HOST = @api_base
    LOGIN_URL = "#{SENDY_HOST}/auth/login".freeze
    SUBSCRIBERS_URL = "#{SENDY_HOST}/api/subscribers".freeze
    EVENTS_URL = "#{SENDY_HOST}/api/events".freeze
    CAMPAIGNS_URL = "#{SENDY_HOST}/api/campaigns".freeze
    CAMPAIGNS_COUNT_URL = "#{SENDY_HOST}/api/campaigns/count.json".freeze
    SUBSCRIBERS_COUNT_URL = "#{SENDY_HOST}/api/subscribers/count.json".freeze
    EVENTS_COUNT_URL = "#{SENDY_HOST}/api/events/count.json".freeze
    TRANSACTIONS_URL = "#{SENDY_HOST}/api/transactions".freeze

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
