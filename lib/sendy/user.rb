module Sendy
  class User < APIResource
    OBJECT_NAME = 'user'.freeze
    extend  Sendy::APIOperations::NestedResource
    include Sendy::APIOperations::Save

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post( "#{Sendy.app_host}/api/add_tokens_to_user", params))
      update_balance(result['balance'])
    end

    def campaigns(params = {})
      Campaign.list(params.merge(user: id))
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
