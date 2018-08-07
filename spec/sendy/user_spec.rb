# frozen_string_literal: true

require 'spec_helper'

describe Sendy::User do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/v1/users")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [user_fixture]))

    stub_request(:post, "http://localhost:3000/v1/users")
      .with(
        body: { 'email' => 'email@example.com' },
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [user_fixture]))

    stub_request(:post, "http://localhost:3000/v1/users/1")
      .with(
        body: {"email"=>"another@email.com"},
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(user_fixture))

    stub_request(:get, "http://localhost:3000/v1/users/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(user_fixture))
  end

  # TODO by ESP only
  it "is not listable" do
    expect { Sendy::User.list }.to raise_error(NotImplementedError)
  end

  it "is retrievable" do
    user = Sendy::User.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/v1/users/1"
    expect(user.is_a?(Sendy::User))
  end

  it "is creatable" do
    user = Sendy::User.create(email: 'email@example.com')
    assert_requested :post, "#{Sendy.app_host}/v1/users"
    expect(user.is_a?(Sendy::User))
  end

  it "is saveable" do
    user = Sendy::User.retrieve("1")
    user.email = 'another@email.com'
    user.save
    assert_requested :post, "#{Sendy.app_host}/v1/users/#{user.id}"
  end

  it "is updateable" do
    user = Sendy::User.update("1", email: "another@email.com")
    assert_requested :post, "#{Sendy.app_host}/v1/users/1"
    expect(user.is_a?(Sendy::User))
  end

  it "is not deletable" do
    user = Sendy::User.retrieve("1")
    expect { user.delete }.to raise_error(NotImplementedError)
  end

  it "can list campaigns" do
    user = Sendy::User.retrieve("1")
    campaigns = user.campaigns
    assert_requested :get, "#{Sendy.app_host}/v1/campaigns"
    expect(campaigns.data.is_a?(Array)).to be true
    expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
  end
end
