module Sendy
  class User
    include Sendy
    include Transaction
    include Campaign
    include Event
    include Subscriber
    
    attr_reader :id, :uid, :balance, :email,
                :api_token, :esp_id, :last_auth_header, :name

    def initialize(args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      add_tokens_to_user_url = "#{Sendy.app_host}/esp_api/v1/add_tokens_to_user"
      result = JSON.parse(RestClient.post( add_tokens_to_user_url, params))
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
