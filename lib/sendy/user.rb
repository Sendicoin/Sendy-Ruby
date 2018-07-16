module Sendy
  class User
    include Sendy
    include Transaction
    include Campaign
    include Event
    include Subscriber
    
    attr_reader :id, :uid, :balance, :email,
                :api_token, :esp_id, :last_auth_header

    def initialize(params)
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

    # ESP Section
    def self.create(params)
      params.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(create_user_url, params))
      self.new(OpenStruct.new(result))
    rescue RestClient::UnprocessableEntity => e
      raise InvalidRequestError.new(JSON.parse(e.response)['errors'])
    end

    def self.find(params)
      params.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(find_user_url, params))
      self.new(OpenStruct.new(result))
    end

    def self.create_user_url
      "#{Sendy.app_host}/auth/signup"
    end

    def self.find_user_url
      "#{Sendy.app_host}/auth/find_user"
    end

    private

    def update_balance(balance)
      @balance = balance
    end
  end
end
