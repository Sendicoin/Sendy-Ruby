module Sendy
  class Subscriber < APIResource
    extend Sendy::APIOperations::List
    extend Sendy::APIOperations::Count

    OBJECT_NAME = 'subscriber'.freeze

    def self.update(_id, _params = nil)
      raise NotImplementedError, "Subscribers cannot be updated"
    end

    def self.create(_params = nil)
      raise NotImplementedError, "Subscribers cannot be created"
    end

    def save(_params = nil)
      raise NotImplementedError, "Subscribers cannot be saved"
    end

    def delete(_params = {})
      raise NotImplementedError, "Subscribers cannot be deleted"
    end

    def events(params = {})
      Event.list(params, { endpoint: Event.resource_endpoint(id, OBJECT_NAME) })
    end

    def campaigns(params = {})
      Campaign.list(params, { endpoint: Campaign.resource_endpoint(id, OBJECT_NAME) })
    end
  end
end
