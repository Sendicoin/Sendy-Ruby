module Sendy
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
      @opened_stake = params[:created_at]
      @clicked_stake = params[:clicked_stake]
      @converted_stake = params[:converted_stake]
      @period_start = params[:period_start]
      @period_end = params[:period_end]
      @initial_balance = params[:initial_balance]
      @status = params[:status]
      @left_over = params[:left_over]
    end

    # def campaigns_count
    #   api_call('get', CAMPAIGNS_COUNT_URL)['count']
    # end

    # def active_campaigns_count
    #   api_call('get', CAMPAIGNS_COUNT_URL, active: true)['count']
    # end

    # def create_campaign(params)
    #   api_call('post', CAMPAIGNS_URL, params)
    # end

    # def campaigns
    #   api_call('get', CAMPAIGNS_URL).map { |campaign| OpenStruct.new(campaign) }
    # end

    # def campaign(campaign_id)
    #   OpenStruct.new(api_call('get', "#{CAMPAIGNS_URL}/#{campaign_id}"))
    # end

    # def campaign_events(campaign_id)
    #   api_call('get', campaign_events_url(campaign_id))
    #     .map { |event| OpenStruct.new(event) }
    # end

    # def campaign_events_url(campaign_id)
    #   "#{CAMPAIGNS_URL}/#{campaign_id}/events"
    # end
  end
end
