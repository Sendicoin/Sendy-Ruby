module Sendy
  class User < APIResource
    OBJECT_NAME = 'user'.freeze
    extend  Sendy::APIOperations::NestedResource
    extend  Sendy::APIOperations::Create
    extend  Sendy::APIOperations::Count
    include Sendy::APIOperations::Save

    def add_tokens(amount)
      params = { uid: uid, amount: amount }
      resp = request(:post, "#{Sendy.app_host}/api/v1/add_tokens_to_user", params)

      # TODO ESP API
      update_balance(resp.balance)
    end

    def campaigns(params = {})
      Campaign.list(params, { endpoint: Campaign.resource_endpoint(id) })
    end

    def transactions(params = {})
      Transaction.list(params, {
                        endpoint: Transaction.resource_endpoint(id),
                        operations: [:list]})
    end

    def events(params = {})
      Event.list(params, { endpoint: Event.resource_endpoint(id),
                           operations: [:list] })
    end

    def subscribers(params = {})
      Subscriber.list(params, { endpoint: Subscriber.resource_endpoint(id),
                                operations: [:list] })
    end

    def self.list(_params = nil)
      raise NotImplementedError, "Users cannot be listed"
    end

    def delete(_params = {})
      raise NotImplementedError, "Users cannot be deleted"
    end

    private

    def update_balance(balance)
      @balance = balance
    end
  end
end
