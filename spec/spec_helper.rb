require 'bundler/setup'
Bundler.setup

require 'sendy'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    request = stub_request(:get, 'http://localhost:3000/auth/signup').
      with(headers: {'Authorization'=>'token'}).
      to_raise(Sendy::AuthenticationError)
  end
end
