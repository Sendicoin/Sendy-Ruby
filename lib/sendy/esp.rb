module Sendy
  class Esp < APIResource

    def self.balance
      resp = request(:get, "#{Sendy.app_host}/esp_api/v1/esp_balance")
      resp.data[:balance]
    end

    def balance
      self.class.balance
    end

    def users(params = {})
      User.list(params)
    end
  end
end
