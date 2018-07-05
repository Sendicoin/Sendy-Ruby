module Sendy
  class Api
    include Sendy

    # attr_accessor :email, :password, :esp_id, :authorization

    # def initialize(esp_id, email, password, authorization = nil)
    #   @esp_id = esp_id
    #   @email = email
    #   @password = password
    #   @authorization = authorization
    # end

    # def login
    #   params = { esp_id: esp_id, email: email, password: password }
    #   @authorization = RestClient.post(LOGIN_URL, params).body
    # end
  end
end
