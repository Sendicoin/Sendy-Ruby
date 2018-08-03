# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Campaign do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/v1/campaigns")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [campaign_fixture]))

    stub_request(:get, "http://localhost:3000/v1/campaigns/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))

    stub_request(:post, "http://localhost:3000/v1/campaigns")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))

    stub_request(:post, "http://localhost:3000/v1/campaigns/1")
      .with(
        body: {"subject"=>"New Subject"},
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))

    stub_request(:delete, "http://localhost:3000/v1/campaigns/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))
  end

  it "listable" do
    campaigns = Sendy::Campaign.list
    assert_requested :get, "#{Sendy.app_host}/v1/campaigns"
    expect(campaigns.data.is_a?(Array)).to be true
    expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
  end

  it "be retrievable" do
    campaign = Sendy::Campaign.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/v1/campaigns/1"
    expect(campaign.is_a?(Sendy::Campaign))
  end

  it "be creatable" do
    campaign = Sendy::Campaign.create
    assert_requested :post, "#{Sendy.app_host}/v1/campaigns"
    expect(campaign.is_a?(Sendy::Campaign))
  end

  it "be saveable" do
    campaign = Sendy::Campaign.retrieve("1")
    campaign.subject = "New Subject"
    campaign.save
    assert_requested :post, "#{Sendy.app_host}/v1/campaigns/#{campaign.id}"
  end

  it "be updateable" do
    campaign = Sendy::Campaign.update("1", subject: "New Subject")
    assert_requested :post, "#{Sendy.app_host}/v1/campaigns/1"
    expect(campaign.is_a?(Sendy::Campaign))
  end

  it "be deletable" do
    campaign = Sendy::Campaign.retrieve("1")
    campaign = campaign.delete
    assert_requested :delete, "#{Sendy.app_host}/v1/campaigns/#{campaign.id}"
    expect(campaign.is_a?(Sendy::Campaign))
  end
end
