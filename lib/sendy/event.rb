module Sendy
  module Event
    def events_count
      api_call('get', Sendy.events)['count']
    end

    def create_event(params)
      Event.new(api_call('post', events_url, params))
    end

    def events
      api_call('get', events_url).map { |event| Event.new(event) }
    end

    def events_count
      api_call('get', "#{events_url}/count")["count"].to_i
    end

    def events_url
      "#{Sendy.app_host}/api/v1/events"
    end

    def campaign_events(api_campaign_id)
      api_call('get', "#{campaigns_url}/#{api_campaign_id}/events").map do |event|
        Event.new(event)
      end
    end

    def subscriber_events(api_subscriber_id)
      api_call('get', "#{subscribers_url}/#{api_subscriber_id}/events").map do |event|
        Event.new(event)
      end
    end

    class Event
      include Sendy

      attr_reader :subscriber_id, :event, :user_id,
                  :campaign_id, :email, :occurred_at, :created_at

      def initialize(args)
        args.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
