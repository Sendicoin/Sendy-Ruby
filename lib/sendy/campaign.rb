module Sendy
  module Campaign

    def create_campaign(params)
      # TODO catch insuficient balance
      Campaign.new(api_call('post', campaigns_url, params))
    end

    def find_campaign(campaign_id)
      Campaign.new(api_call('get', "#{campaigns_url}/#{campaign_id}"))
    end

    def campaigns
      api_call('get', campaigns_url).map { |campaign| Campaign.new(campaign) }
    end

    def campaigns_url
      "#{Sendy.app_host}/api/v1/campaigns"
    end

    def campaigns_count
      api_call('get', "#{campaigns_url}/count")["count"].to_i
    end

    class Campaign
      include Sendy

      attr_reader :id, :user_id, :created_at, :updated_at,
                  :subject, :balance, :opened_stake, :clicked_stake, :converted_stake,
                  :period_start, :period_end, :initial_balance, :status, :left_over,
                  :opened_count, :clicked_count, :converted_count, :one_stake,
                  :total_stakes, :subscribers_send_count


      def initialize(args)
        args.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
