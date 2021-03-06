require 'spec_helper'

describe "mocked API requests to tokenize_by_direct_post" do
  let(:live_response) do
    Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    )
  end

  def run_mocked_response
    Vantiv::MockedSandbox.enable_self_mocked_requests!
    Vantiv.tokenize_by_direct_post(
      card_number: card.card_number,
      expiry_month: card.expiry_month,
      expiry_year: card.expiry_year,
      cvv: card.cvv,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    ).tap do
      Vantiv::MockedSandbox.disable_self_mocked_requests!
    end
  end

  let(:mocked_response) { run_mocked_response }

  Vantiv::TestCard.all.each do |test_card|
    let(:card) { test_card }

    context "with a #{test_card.name}" do
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
  end
end
