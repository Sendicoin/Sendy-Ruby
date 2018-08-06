module Sendy
  class Transaction < APIResource
    extend Sendy::APIOperations::List
    extend Sendy::APIOperations::Create
    include Sendy::APIOperations::Save

    OBJECT_NAME = 'transaction'.freeze

    def self.update(_id, _params = nil)
      raise NotImplementedError, "Transactions cannot be updated"
    end

    def self.create(_params = nil)
      raise NotImplementedError, "Transactions cannot be created"
    end

    def save(_params = nil)
      raise NotImplementedError, "Transactions cannot be saved"
    end

    def delete(_params = {})
      raise NotImplementedError, "Transactions cannot be deleted"
    end
  end
end
