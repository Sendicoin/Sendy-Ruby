module Sendy
  class User
    include Sendy
    include Transaction
    include Campaign
    include Event
    
    attr_reader :id, :uid, :balance, :email, :password, :esp_id, :last_auth_header

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
      @last_auth_header = RestClient.post(LOGIN_URL, params).body
    end

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(ADD_TOKENS_URL, params))
      update_balance(result['balance'])
    end

    # ESP Section
    def self.create(params)
      # TODO SENDY API SHOULD RETURN IF UID IS CAPTURED
      # validate params

      api_password = SecureRandom.hex
      params.merge!(Sendy.esp_login_params)
      params.merge!(password: api_password)
      result = JSON.parse(RestClient.post(CREATE_USER_URL, params))
      self.new(OpenStruct.new(result.merge!(password: api_password)))
    rescue RestClient::UnprocessableEntity => e
      raise InvalidRequestError.new(JSON.parse(e.response)['errors'])
    end

    def self.find(params)
      params.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(FIND_USER_URL, params))
      self.new(OpenStruct.new(result))
    end

    private

    def update_balance(balance)
      @balance = balance
    end
  end
end
