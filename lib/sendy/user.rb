module Sendy
  class User
    include Sendy
    
    attr_reader :id, :uid, :balance, :email, :password

    def initialize(params)
      @id = params[:id]
      @uid = params[:uid]
      @balance = params[:balance]
      @email = params[:email]
      @password = params[:password] if params[:password]
    end

    def add_tokens(amount)
      # TODO
      # Bad path validation necessary with error exceptions
      params = { uid: uid, amount: amount }.merge!(Sendy.esp_login_params)
      result = JSON.parse(RestClient.post(ADD_TOKENS_URL, params))
      update_balance(result['balance'])
    end

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
