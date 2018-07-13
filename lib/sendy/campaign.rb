module Sendy
  module Campaign

    def create_campaign(params)
      # TODO catch insuficient balance
      Campaign.new(OpenStruct.new(api_call('post', campaigns_url, params)))
    end

    def find_campaign(campaign_id)
      Campaign.new(OpenStruct.new(api_call('get', "#{campaigns_url}/#{campaign_id}")))
    end

    def campaigns
      api_call('get', campaigns_url).map { |campaign| Campaign.new(OpenStruct.new(campaign)) }
    end

    def campaigns_url
      "#{Sendy.app_host}/api/campaigns"
    end

    class Campaign
      include Sendy

      attr_reader :id, :uid, :user_id, :created_at, :updated_at,
                  :subject, :balance, :opened_stake, :clicked_stake, :converted_stake,
                  :period_start, :period_end, :initial_balance, :status, :left_over

      def initialize(params)
        @id = params[:id]
        @uid = params[:uid]
        @user_id = params[:user_id]
        @created_at = params[:created_at]
        @updated_at = params[:updated_at]
        @subject = params[:subject]
        @balance = params[:balance]
        @opened_stake = params[:opened_stake]
        @clicked_stake = params[:clicked_stake]
        @converted_stake = params[:converted_stake]
        @period_start = params[:period_start]
        @period_end = params[:period_end]
        @initial_balance = params[:initial_balance]
        @status = params[:status]
        @left_over = params[:left_over]
      end
    end
  end
end
