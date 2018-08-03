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

    stub_request(:get, 'http://localhost:3000/v1/users/cus_123').
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

