module Sendy
  class Event
    def events_count
      api_call('get', EVENTS_COUNT_URL)['count']
    end

    def create_event(params)
      api_call('post', EVENTS_URL, params)
    end

    def events
      api_call('get', EVENTS_URL).map { |event| OpenStruct.new(event) }
    end
  end
end
