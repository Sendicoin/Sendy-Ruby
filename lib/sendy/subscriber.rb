module Sendy
  module Subscriber
    def subscribers_count
      api_call('get', subscribers_count_url)['count']
    end

    def subscribers
      api_call('get', subscribers_url).map do |subscriber|
        Subscriber.new(OpenStruct.new(subscriber))
      end
    end

    def subscriber(subscriber_id)
      Subscriber.new(OpenStruct.new(api_call('get', "#{subscribers_url}/#{subscriber_id}")))
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

    def subscribers_url
      "#{Sendy.app_host}/api/subscribers"
    end

    class Subscriber
      include Sendy
      attr_reader :email, :balance, :name

      def initialize(params)
        @email = params[:email]
        @balance = params[:balance]
        @name = params[:name]
      end
    end
  end
end
