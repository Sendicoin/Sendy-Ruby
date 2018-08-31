module Sendy
  class Event < APIResource
    extend Sendy::APIOperations::List
    extend Sendy::APIOperations::Create
    extend Sendy::APIOperations::Count

    OBJECT_NAME = 'event'.freeze

    def self.update(_id, _params = nil)
      raise NotImplementedError, 'Events cannot be updated'
    end

    def save(_params = nil)
      raise NotImplementedError, 'Events cannot be saved'
    end

    def delete(_params = {})
      raise NotImplementedError, 'Events cannot be deleted'
    end
  end
end
