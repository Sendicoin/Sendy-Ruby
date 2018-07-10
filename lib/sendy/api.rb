module Sendy
  class Api
    include Sendy
    include Sendy::User
    include Sendy::Transaction
    include Sendy::Event
    include Sendy::Campaign
    include Sendy::Subscriber

    attr_accessor :email, :password, :esp_id, :authorization

    def initialize(esp_id, email, password, authorization = nil)
      @esp_id = esp_id
      @email = email
      @password = password
      @authorization = authorization
    end
  end
end
