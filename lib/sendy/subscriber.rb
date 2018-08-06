module Sendy
  class Subscriber < APIResource
    extend Sendy::APIOperations::List

    OBJECT_NAME = 'subscriber'.freeze

    def subscribers_count
      api_call('get', subscribers_count_url)['count']
    end

    def subscribers
      api_call('get', subscribers_url).map do |subscriber|
        Subscriber.new(OpenStruct.new(subscriber))
      end
    end

    def find_subscriber(params)
      Subscriber.new(OpenStruct.new(api_call('get', "#{subscribers_url}/show", params)))
    end

    def subscriber_events(subscriber_id)
      events.select { |event| event.subscriber_id == subscriber_id.to_i }
    end

    def subscriber_campaigns(subscriber_id)
      api_call('get', subscribers_campaigns_url(subscriber_id)).map do |campaign|
        Campaign.new(OpenStruct.new(campaign))
      end
    end

    def subscribers_campaigns_url(subscriber_id)
      "#{subscribers_url}/#{subscriber_id}/campaigns"
    end

    def subscriber_campaign(subscriber_id, campaign_id)
      subscriber_campaigns(subscriber_id)
        .select { |campaign| campaign.id == campaign_id.to_i }.first
    end

    def subscribers_count_url
      "#{Sendy.app_host}/api/subscribers/count.json"
    end

    def self.update(_id, _params = nil)
      raise NotImplementedError, "Subscribers cannot be updated"
    end

    def self.create(_params = nil)
      raise NotImplementedError, "Subscribers cannot be created"
    end

    def save(_params = nil)
      raise NotImplementedError, "Subscribers cannot be saved"
    end

    def delete(_params = {})
      raise NotImplementedError, "Subscribers cannot be deleted"
    end
  end
end
