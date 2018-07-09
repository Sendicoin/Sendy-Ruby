module Sendy
  class Campaign
    def campaigns_count
      api_call('get', CAMPAIGNS_COUNT_URL)['count']
    end

    def active_campaigns_count
      api_call('get', CAMPAIGNS_COUNT_URL, active: true)['count']
    end

    def create_campaign(params)
      api_call('post', CAMPAIGNS_URL, params)
    end

    def campaigns
      api_call('get', CAMPAIGNS_URL).map { |campaign| OpenStruct.new(campaign) }
    end

    def campaign(campaign_id)
      OpenStruct.new(api_call('get', "#{CAMPAIGNS_URL}/#{campaign_id}"))
    end

    def campaign_events(campaign_id)
      api_call('get', campaign_events_url(campaign_id))
        .map { |event| OpenStruct.new(event) }
    end

    def campaign_events_url(campaign_id)
      "#{CAMPAIGNS_URL}/#{campaign_id}/events"
    end
  end
end
