module Sendy
  class User
    def current_balance
      Users.find_user(user)['balance'] || '0.0'
    end

    def self.add_tokens(user, amount)
      params = { user_id: user.sendy.uid, amount: amount}.merge!(Sendy.esp_login_params)
      JSON.parse(RestClient.post(ADD_TOKENS_URL, params))
    rescue RestClient::NotAcceptable => e
      raise Api::IncorrectTransaction.new(e.response.to_s)
    end

    def self.create_user(user)
      api_password = SecureRandom.hex
      params = create_user_params(user, api_password)
      result = JSON.parse(RestClient.post(CREATE_USER_URL, params))
      if !user.sendy
        Users.create!(user_id: user.id, uid: result['user_id'],
                      user_name: user.email, password: api_password)
      else
        user.sendy.update(user_name: user.email, password: api_password)
      end
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
