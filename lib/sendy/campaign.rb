module Sendy
  class Campaign < APIResource
    extend Sendy::APIOperations::List
    extend Sendy::APIOperations::Create

    OBJECT_NAME= 'campaign'.freeze

    def self.update(_id, _params = nil)
      raise NotImplementedError, "Campaigns cannot be updated"
    end

    def save(_params = nil)
      raise NotImplementedError, "Campaigns cannot be saved"
    end

    def delete(_params = {})
      raise NotImplementedError, "Campaigns cannot be deleted"
    end

    def events(params = {})
      Event.list(params, { endpoint: Event.resource_endpoint(id, OBJECT_NAME) })
    end
  end
end
