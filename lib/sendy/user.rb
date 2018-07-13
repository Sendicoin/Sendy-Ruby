module Sendy
  class User
    include Sendy
    include Transaction
    include Campaign
    include Event
    include Subscriber
    
    attr_reader :id, :uid, :balance, :email,
                :password, :esp_id, :last_auth_header

    def initialize(params)
      @id = params[:id]
      @uid = params[:uid]
      @balance = params[:balance]
      @email = params[:email]
      @password = params[:password] if params[:password]
      @esp_id = params[:esp_id] || 1
    end

    def login
      params = { esp_id: esp_id, email: email, password: password }
      @last_auth_header = RestClient.post(login_url, params).body
    end

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(add_tokens_url, params))
      update_balance(result['balance'])
    end

    def assign_api_password(password)
      @password = password
    end

    # ESP Section
    def self.create(params)
      # TODO SENDY API SHOULD RETURN IF UID IS CAPTURED
      # validate params

      api_password = SecureRandom.hex
      params.merge!(Sendy.esp_login_params)
      params.merge!(password: api_password)
      result = JSON.parse(RestClient.post(create_user_url, params))
      self.new(OpenStruct.new(result.merge!(password: api_password)))
    rescue RestClient::UnprocessableEntity => e
      raise InvalidRequestError.new(JSON.parse(e.response)['errors'])
    end

    def self.find(params)
      params.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(find_user_url, params))
      self.new(OpenStruct.new(result))
    end

    def login_url
      "#{Sendy.app_host}/auth/login"
    end

    def create_user_url
      "#{Sendy.app_host}/auth/signup"
    end

    def self.find_user_url
      "#{Sendy.app_host}/auth/find_user"
    end

    def add_tokens_url
      "#{Sendy.app_host}/api/add_tokens_to_user"
    end

    private

    def update_balance(balance)
      @balance = balance
    end
  end
end
