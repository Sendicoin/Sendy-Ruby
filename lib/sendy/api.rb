module Sendy
  class Api
    include Sendy
    include User
    include Transaction
    include Event
    include Campaign
    include Subscriber

    attr_accessor :email, :password, :esp_id, :authorization

    def initialize(esp_id, email, password, authorization = nil)
      @esp_id = esp_id
      @email = email
      @password = password
      @authorization = authorization
    end
  end
end
