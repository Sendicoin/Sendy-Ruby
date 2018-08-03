module Sendy
  class User < APIResource
    OBJECT_NAME = 'user'.freeze
    extend  Sendy::APIOperations::NestedResource
    include Sendy::APIOperations::Save

    nested_resource_class_methods :campaign, operations: %i[create retrieve list]

    def old_initialize(params)
      # @TODO
      @id = params[:id]
      @uid = params[:uid]
      @balance = params[:balance]
      @email = params[:email]
      @api_token = params[:api_token] if params[:api_token]
      @esp_id = params[:esp_id] || 1
    end

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

    private

    def update_balance(balance)
      @balance = balance
    end
  end
end
