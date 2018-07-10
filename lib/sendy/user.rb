module Sendy
  class User
    include Sendy
    
    attr_reader :id, :uid, :balance, :email, :password

    def initialize(params)
      @id = params[:id]
      @uid = params[:uid]
      @balance = params[:balance]
      @email = params[:email]
      @password = params[:password]
    end

    def self.add_tokens(user, amount)
      params = { user_id: user.sendy.uid, amount: amount}.merge!(Sendy.esp_login_params)
      JSON.parse(RestClient.post(ADD_TOKENS_URL, params))
    rescue RestClient::NotAcceptable => e
      raise Api::IncorrectTransaction.new(e.response.to_s)
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

    def self.user_exists?(user)
      find_user(user) && find_user(user)['uid'] == user.id.to_s
    end

    def self.find_user(user)
      params = { uid: user.id }.merge!(Sendy.esp_login_params)
      JSON.parse(RestClient.post(FIND_USER_URL, params))
    rescue RestClient::NotFound
      false
    end

    private

    # def sendy_api
    #   @sendy ||= SendyApi.new(1, user.email, password, last_auth_header)
    # end

    def self.create_user_params(user, api_password)
      {
        uid: user.id,
        email: user.email,
        password: api_password
      }.merge!(Sendy.esp_login_params)
    end
  end
end
