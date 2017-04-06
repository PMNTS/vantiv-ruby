require 'spec_helper'

describe "reversing authorizations" do
  let(:test_account) { Vantiv::TestAccount.valid_account }
  let(:payment_account_id) { test_account.payment_account_id }
  let(:transaction_id) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: "Anything-#{rand(10000)}",
      order_id: "AnyOrder#{rand(100000)}",
      expiry_month: test_account.expiry_month,
      expiry_year: test_account.expiry_year,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    ).transaction_id
  end
  let(:amount) { nil }

  def run_reversal(transaction_id)
    Vantiv.auth_reversal(
      transaction_id: transaction_id,
      amount: amount,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    )
  end

  def expect_successful_response(response)
    expect(response.success?).to eq true
    expect(response.failure?).to eq false
    expect(response.response_code).to eq '001'
  end

  it "returns success when the reversal is received" do
    expect(run_reversal(transaction_id).success?).to eq(true)
  end

  it "returns a new transaction id" do
    response = run_reversal(transaction_id)
    expect(response.transaction_id).not_to eq nil
    expect(response.transaction_id).not_to eq ""
    expect(response.transaction_id).not_to eq transaction_id
  end

  it "returns a 001 transaction received response code" do
    expect(run_reversal(transaction_id).response_code).to eq '001'
    expect(run_reversal(transaction_id).message).to eq 'Transaction Received'
  end

  context "when nonexistent transaction is used" do
    let(:transaction_id) { "99997933698012190" }

    it "has a successful response" do
      response = run_reversal(transaction_id)
      expect_successful_response(response)
    end
  end

  context "when reversing a specific amount of the authorization" do
    let(:amount) { 1000 }

    it "has a successful response" do
      response = run_reversal(transaction_id)
      expect_successful_response(response)
    end
  end

  context "when reversing an amount exceeding the authorization" do
    let(:amount) { 20000 }

    it "has a successful response" do
      response = run_reversal(transaction_id)
      expect_successful_response(response)
    end
  end

  context "when the remaining amount after capturing an auth" do
    let(:capture_transaction_id) do
      Vantiv.capture(
        transaction_id: transaction_id,
        amount: amount,
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      ).transaction_id
    end
    let(:amount) { 5000 }

    it "has a successful response" do
      response = run_reversal(capture_transaction_id)
      expect_successful_response(response)
    end

    context "when reversing a specific amount from the capture" do

      it "has a successful response" do
        response = run_reversal(capture_transaction_id)
        expect_successful_response(response)
      end
    end

    context "when reversing an amount exceeding the capture" do
      let(:amount) { 99999 }

      it "has a successful response" do
        response = run_reversal(capture_transaction_id)
        expect_successful_response(response)
      end
    end
  end
end
