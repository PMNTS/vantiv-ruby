require 'spec_helper'
require 'vantiv/certification/paypage_driver'

describe "mocked API requests to .tokenize" do
  def run_mocked_response
    Vantiv::MockedSandbox.enable_self_mocked_requests!

    Vantiv.tokenize(
      temporary_token: mocked_temporary_token,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    ).tap do
      Vantiv::MockedSandbox.disable_self_mocked_requests!
    end
  end

  let(:mocked_response) { run_mocked_response }

  let(:live_response) do
    Vantiv.tokenize(
      temporary_token: live_temporary_token,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    )
  end

  before :all do
    @test_paypage_driver = Vantiv::Certification::PaypageDriver.new
    @test_paypage_driver.start
  end

  after :all do
    @test_paypage_driver.stop
  end

  context "with a valid temporary token" do
    let(:card) { Vantiv::TestCard.valid_account }

    let(:live_temporary_token) do
      @test_paypage_driver.get_paypage_registration_id(
        card.card_number,
        card.cvv
      )
    end

    let(:mocked_temporary_token) do
      Vantiv::TestTemporaryToken.valid_temporary_token
    end

    it "returns the same attributes in the live and mocked responses" do
      expect(live_response.success?).to eq mocked_response.success?
      expect(live_response.failure?).to eq mocked_response.failure?
      expect(live_response.message).to eq mocked_response.message
      expect(live_response.error_message).to eq mocked_response.error_message
      expect(live_response.httpok).to eq mocked_response.httpok
      expect(live_response.http_response_code).to eq mocked_response.http_response_code
      expect(live_response.api_level_failure?).to eq mocked_response.api_level_failure?
      expect(live_response.raw_body.length).to eq mocked_response.raw_body.length
    end

    it "returns the whitelisted payment account id" do
      expect(mocked_response.payment_account_id).to eq card.mocked_sandbox_payment_account_id
    end

    it "returns a dynamic transaction id" do
      response_1 = run_mocked_response
      response_2 = run_mocked_response
      expect(response_1.transaction_id).not_to eq response_2.transaction_id
    end
  end

  context "with an expired temporary token" do
    let(:live_temporary_token) do
      # test token that always returns an expired response
      "RGFQNCt6U1d1M21SeVByVTM4dHlHb1FsVkUrSmpnWXhNY0o5UkMzRlZFanZiUHVnYjN1enJXbG1WSDF4aXlNcA=="
    end

    let(:mocked_temporary_token) do
      Vantiv::TestTemporaryToken.expired_temporary_token
    end

    it "returns the same attributes in the live and mocked responses" do
      expect(live_response.success?).to eq mocked_response.success?
      expect(live_response.failure?).to eq mocked_response.failure?
      expect(live_response.message).to eq mocked_response.message
      expect(live_response.error_message).to eq mocked_response.error_message
      expect(live_response.httpok).to eq mocked_response.httpok
      expect(live_response.http_response_code).to eq mocked_response.http_response_code
      expect(live_response.api_level_failure?).to eq mocked_response.api_level_failure?
      expect(mocked_response.raw_body).to be_an_instance_of String
    end

    it "returns a dynamic transaction id" do
      response_1 = run_mocked_response
      response_2 = run_mocked_response
      expect(response_1.transaction_id).not_to eq response_2.transaction_id
    end
  end

  context "with an invalid temporary token" do
    let(:live_temporary_token) do
      # test token that always returns an invalid response
      "pDZJcmd1VjNlYXNaSlRMTGpocVZQY1NWVXE4Z W5UTko4NU9KK3p1L1p1Vzg4YzVPQVlSUHNITG1 JN2I0NzlyTg=="
    end

    let(:mocked_temporary_token) do
      Vantiv::TestTemporaryToken.invalid_temporary_token
    end

    it "returns the same attributes in the live and mocked responses" do
      expect(live_response.success?).to eq mocked_response.success?
      expect(live_response.failure?).to eq mocked_response.failure?
      expect(live_response.message).to eq mocked_response.message
      expect(live_response.error_message).to eq mocked_response.error_message
      expect(live_response.httpok).to eq mocked_response.httpok
      expect(live_response.http_response_code).to eq mocked_response.http_response_code
      expect(live_response.api_level_failure?).to eq mocked_response.api_level_failure?
      expect(mocked_response.raw_body).to be_an_instance_of String
    end

    it "returns a dynamic transaction id" do
      response_1 = run_mocked_response
      response_2 = run_mocked_response
      expect(response_1.transaction_id).not_to eq response_2.transaction_id
    end
  end
end
