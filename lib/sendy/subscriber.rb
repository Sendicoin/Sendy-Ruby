module Sendy
  module Subscriber
    def subscribers_count
      api_call('get', "#{subscribers_url}/count")['count'].to_i
    end

    def subscribers
      api_call('get', subscribers_url).map do |subscriber|
        Subscriber.new(subscriber)
      end
    end

    def find_subscriber(api_subscriber_id)
      Subscriber.new(api_call('get', "#{subscribers_url}/#{api_subscriber_id}"))
    end

    def subscriber_campaigns(api_subscriber_id)
      api_call('get', "#{subscribers_url}/#{api_subscriber_id}/campaigns").map do |campaign|
        Campaign::Campaign.new(campaign)
      end
    end

    def subscriber_campaign(api_subscriber_id, api_campaign_id)
      subscriber_campaigns(api_subscriber_id)
        .select { |campaign| campaign.id == api_campaign_id.to_i }.first
    end

    def subscriber_by_email(email)
      Subscriber.new(api_call('get', "#{subscribers_url}/show_by_email", { email: email }))
    end

    def subscribers_url
      "#{Sendy.app_host}/api/v1/subscribers"
    end

    class Subscriber
      include Sendy
      attr_reader :email, :balance, :name,
                  :sign_up_url, :coins_human, :coins_usd, :confirmed_at

      def initialize(args)
        args.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
