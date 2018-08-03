module Sendy
  class Event < APIResource
    extend  Sendy::APIOperations::List
    OBJECT_NAME = 'event'.freeze

    def events_count
      api_call('get', Sendy.events)['count']
    end

    def create_event(params)
      Event.new(OpenStruct.new(api_call('post', events_url, params)))
    end

    def events
      api_call('get', events_url).map { |event| Event.new(OpenStruct.new(event)) }
    end
  end
end
