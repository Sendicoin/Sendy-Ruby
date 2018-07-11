module Sendy
  module Event
    
    def events_count
      api_call('get', EVENTS_COUNT_URL)['count']
    end

    def create_event(params)
      Event.new(OpenStruct.new(api_call('post', EVENTS_URL, params)))
    end

    def events
      api_call('get', EVENTS_URL).map { |event| Event.new(OpenStruct.new(event)) }
    end

    class Event
      include Sendy

      attr_reader :subscriber_id, :event, :user_id,
                  :campaign_id, :email, :occurred_at, :created_at
      
      def initialize(params)
        @subscriber_id = params[:subscriber_id]
        @event = params[:event]
        @user_id = params[:user_id]
        @campaign_id = params[:campaign_id]
        @email = params[:email]
        @occurred_at = params[:occurred_at]
        @created_at = params[:created_at]
      end
    end
  end
end
