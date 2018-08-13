module Sendy
  class User < APIResource
    OBJECT_NAME = 'user'.freeze
    extend  Sendy::APIOperations::NestedResource
    extend  Sendy::APIOperations::Create
    extend  Sendy::APIOperations::Count
    include Sendy::APIOperations::Save

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post( "#{Sendy.app_host}/api/add_tokens_to_user", params))
      update_balance(result['balance'])
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
      Event.list(params, { endpoint: Event.resource_endpoint(id) })
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
