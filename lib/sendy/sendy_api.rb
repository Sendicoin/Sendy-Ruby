module Sendy
  class SendyApi
    class DuplicateEvent < StandardError; end
    class InvalidParams < StandardError; end
    class InternalAPIError < StandardError; end
    class IncorrectTransaction < StandardError; end

    attr_accessor :email, :password, :esp_id, :authorization
  SENDY_HOST = @api_base
  LOGIN_URL = "#{'SENDY_HOST'}/auth/login"
  
  SUBSCRIBERS_URL = "#{'SENDY_HOST'}/api/subscribers"
  EVENTS_URL = "#{'SENDY_HOST'}/api/events"
  CAMPAIGNS_URL = "#{'SENDY_HOST'}/api/campaigns"
  
  CAMPAIGNS_COUNT_URL = "#{'SENDY_HOST'}/api/campaigns/count.json"
  SUBSCRIBERS_COUNT_URL = "#{'SENDY_HOST'}/api/subscribers/count.json"
  EVENTS_COUNT_URL = "#{'SENDY_HOST'}/api/events/count.json"

  TRANSACTIONS_URL = "#{'SENDY_HOST'}/api/transactions"

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

    def campaigns_count
      api_call('get', CAMPAIGNS_COUNT_URL)['count']
    end

    def active_campaigns_count
      api_call('get', CAMPAIGNS_COUNT_URL, {active: true})['count']
    end

    def subscribers_count
      api_call('get', SUBSCRIBERS_COUNT_URL)['count']
    end

    def events_count
      api_call('get', EVENTS_COUNT_URL)['count']
    end
    
    def create_event(params)
      api_call('post', EVENTS_URL, params)
    end
    
    def create_campaign(params)
      api_call('post', CAMPAIGNS_URL, params)
    end

    def campaigns
      api_call('get', CAMPAIGNS_URL).map{|campaign| OpenStruct.new(campaign)}
    end

    def subscribers
      api_call('get', SUBSCRIBERS_URL).map{|subscriber| OpenStruct.new(subscriber)}
    end

    def events
      api_call('get', EVENTS_URL).map{|event| OpenStruct.new(event)}
    end

    def campaign(campaign_id)
      OpenStruct.new(api_call('get', "#{CAMPAIGNS_URL}/#{campaign_id}"))
    end

    def campaign_events(campaign_id)
      api_call('get', campaign_events_url(campaign_id)).map{|event| OpenStruct.new(event)}
    end

    def campaign_events_url(campaign_id)
      "#{CAMPAIGNS_URL}/#{campaign_id}/events"
    end

    def transactions
      api_call('get', TRANSACTIONS_URL).map{|transaction| OpenStruct.new(transaction)}
    end

    def subscriber(subscriber_id)
      OpenStruct.new(api_call('get', "#{SUBSCRIBERS_URL}/#{subscriber_id}"))
    end

    def subscriber_events(subscriber_id)
      events.select { |event| event.subscriber_id == subscriber_id.to_i }
    end

    def subscriber_campaigns(subscriber_id)
      api_call('get', subscribers_campaigns_url(subscriber_id))
        .map{|campaign| OpenStruct.new(campaign)}
    end

    def subscribers_campaigns_url(subscriber_id)
      "#{SUBSCRIBERS_URL}/#{subscriber_id}/campaigns"
    end

    def subscriber_campaign(subscriber_id, campaign_id)
      subscriber_campaigns(subscriber_id)
        .select { |campaign| campaign.id == campaign_id.to_i }.first
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
