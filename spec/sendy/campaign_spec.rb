# frozen_string_literal: true

require 'spec_helper'

describe Sendy::Campaign do
  before do
    Sendy.app_host = 'http://localhost:3000'
    Sendy.app_esp_password = 'valid_api_token'

    stub_request(:get, "http://localhost:3000/api/v1/campaigns")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(data: [campaign_fixture]))

    stub_request(:get, "http://localhost:3000/api/v1/campaigns/1")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))

    stub_request(:post, "http://localhost:3000/api/v1/campaigns")
      .with(
        headers: {
          'Authorization'=>'token valid_api_token',
        })
      .to_return(body: JSON.generate(campaign_fixture))
  end

  it "is listable" do
    campaigns = Sendy::Campaign.list
    assert_requested :get, "#{Sendy.app_host}/api/v1/campaigns"
    expect(campaigns.data.is_a?(Array)).to be true
    expect(campaigns.first.is_a?(Sendy::Campaign)).to be true
  end

  it "is retrievable" do
    campaign = Sendy::Campaign.retrieve("1")
    assert_requested :get, "#{Sendy.app_host}/api/v1/campaigns/1"
    expect(campaign.is_a?(Sendy::Campaign))
  end

  it "is creatable" do
    campaign = Sendy::Campaign.create
    assert_requested :post, "#{Sendy.app_host}/api/v1/campaigns"
    expect(campaign.is_a?(Sendy::Campaign))
  end

  it "is not saveable" do
    campaign = Sendy::Campaign.retrieve("1")
    campaign.subject = "New Subject"
    expect { campaign.save }.to raise_error(NotImplementedError)
    assert_not_requested :post, "#{Sendy.app_host}/api/v1/campaigns/#{campaign.id}"
  end

  it "is not updateable" do
    expect do
      Sendy::Campaign.update("1", subject: "New Subject")
    end.to raise_error(NotImplementedError)
  end

  it "is not deletable" do
    campaign = Sendy::Campaign.retrieve("1")
    expect { campaign.delete }.to raise_error(NotImplementedError)
  end

  context "#events" do
    before do
      stub_request(:get, "http://localhost:3000/api/v1/campaigns/1/events")
        .with(
          headers: {
            'Authorization'=>'token valid_api_token',
          })
        .to_return(body: JSON.generate(data: [event_fixture]))

      stub_request(:post, "http://localhost:3000/api/v1/campaigns/1/events")
        .with(
          body: {"email"=>"email@example.com", "event" => "opened"},
          headers: {
            'Authorization'=>'token valid_api_token',
          })
            .to_return(body: JSON.generate(event_fixture))
    end

    it "can list events" do
      campaign = Sendy::Campaign.retrieve("1")
      events = campaign.events
      assert_requested :get, "#{Sendy.app_host}/api/v1/campaigns/1/events"
      expect(events.data.is_a?(Array)).to be true
      expect(events.first.is_a?(Sendy::Event)).to be true
    end

    it "can create events" do
      campaign = Sendy::Campaign.retrieve("1")
      event = campaign.events.create(email: 'email@example.com', event: 'opened')
      assert_requested :post, "#{Sendy.app_host}/api/v1/campaigns/1/events"
      expect(event.campaign_id).to eql(campaign.id)
      expect(event.is_a?(Sendy::Event)).to be true
    end
  end
end
