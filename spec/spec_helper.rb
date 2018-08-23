require 'bundler/setup'
Bundler.setup

require 'sendy'
require 'webmock/rspec'
require 'byebug'

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, 'http://localhost:3000/auth/signup').
      with(headers: {'Authorization'=>'token'}).
      to_raise(Sendy::AuthenticationError)

    stub_request(:get, 'http://localhost:3000/api/v1/transactions/123').
      with(headers: {'Authorization'=>'token'}).
      to_raise(Sendy::AuthenticationError)
  end
end

def campaign_fixture
  {
    "object": 'campaign',
    "balance": 10,
    "clicked_count": 1,
    "clicked_stake": 2,
    "converted_count": 0,
    "converted_stake": 20,
    "created_at": "2018-07-31T16:10:59.239Z",
    "id": 1,
    "initial_balance": 10,
    "left_over": 0,
    "opened_count": 1,
    "opened_stake": 1,
    "period_end": "2018-07-31T03:00:00.000Z",
    "period_start": "2018-07-31T01:10:00.000Z",
    "status": "started",
    "subject": "Sendy Test",
    "uid": "2",
    "updated_at": "2018-07-31T16:10:59.239Z",
    "user_id": 1
  }
end

def event_fixture
  {
    "object": "event",
    "campaign_id": 1,
    "created_at": "2018-07-31T16:19:06.893Z",
    "email": "email@example.com",
    "event": "opened",
    "id": 1,
    "occurred_at": "2018-07-31T16:18:45.000Z",
    "subscriber_id": 1,
    "updated_at": "2018-07-31T16:19:06.893Z",
    "user_id": 1
  }
end

def subscriber_fixture
  {
    "object": "subscriber",
    "balance": 0,
    "created_at": "2018-07-31T16:19:06.729Z",
    "email": "email@example.com",
    "id": 1,
    "name": "Marcos Teixeira",
    "sign_up_url": "http://localhost:3000/sign_up_by_email/WaNy6nBh67dPz2ZphwsQEYVj",
    "signed_up_at": nil,
    "updated_at": "2018-07-31T16:25:14.632Z"
  }
end

def transaction_fixture
  {
    "object": 'transaction',
    "amount": 1,
    "campaign_id": nil,
    "created_at": "2018-07-31T16:02:14.108Z",
    "esp_id": 1,
    "eth_tx": nil,
    "from_address": nil,
    "id": 1,
    "subscriber_id": nil,
    "to_address": nil,
    "type": "EspToUserTxRecord",
    "updated_at": "2018-07-31T16:02:14.108Z",
    "user_id": 1
  }
end

def user_fixture
  {
    "object": 'user',
    "id":1,
    "email":"support@sendicate.net",
    "created_at":"2018-07-31T15:01:40.237Z",
    "updated_at":"2018-07-31T15:01:40.237Z",
    "balance":41,
    "uid":"1",
    "esp_id":1,
    "api_token":"CXasPzXK3r3C52asgMv8vMk2"
  }
end
