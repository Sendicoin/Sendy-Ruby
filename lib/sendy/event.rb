module Sendy
  class Event < APIResource
    extend  Sendy::APIOperations::List
    extend Sendy::APIOperations::Create
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

    def self.update(_id, _params = nil)
      raise NotImplementedError, "Events cannot be updated"
    end

    def save(_params = nil)
      raise NotImplementedError, "Events cannot be saved"
    end

    def delete(_params = {})
      raise NotImplementedError, "Events cannot be deleted"
    end
  end
end
