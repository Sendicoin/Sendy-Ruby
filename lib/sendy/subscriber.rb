module Sendy
  class Subscriber
    include Sendy
    def subscribers_count
      api_call('get', SUBSCRIBERS_COUNT_URL)['count']
    end

    def subscribers
      api_call('get', SUBSCRIBERS_URL).map { |subscriber| OpenStruct.new(subscriber) }
    end

    def subscriber(subscriber_id)
      OpenStruct.new(api_call('get', "#{SUBSCRIBERS_URL}/#{subscriber_id}"))
    end

    def subscriber_events(subscriber_id)
      events.select { |event| event.subscriber_id == subscriber_id.to_i }
    end

    def subscriber_campaigns(subscriber_id)
      api_call('get', subscribers_campaigns_url(subscriber_id))
        .map { |campaign| OpenStruct.new(campaign) }
    end

    def subscribers_campaigns_url(subscriber_id)
      "#{SUBSCRIBERS_URL}/#{subscriber_id}/campaigns"
    end

    def subscriber_campaign(subscriber_id, campaign_id)
      subscriber_campaigns(subscriber_id)
        .select { |campaign| campaign.id == campaign_id.to_i }.first
    end
  end
end
