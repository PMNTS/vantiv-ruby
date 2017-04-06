require 'spec_helper'

describe "account updater" do
  let(:payment_account_id) { test_account.payment_account_id }

  subject(:account_updater_response) do
    Vantiv.auth(
      amount: 10000,
      payment_account_id: payment_account_id,
      customer_id: "1234",
      order_id: "SomeOrder123",
      expiry_month: test_account.expiry_month,
      expiry_year: test_account.expiry_year,
      merchant_id: $test_merchant_id,
      user: $test_user,
      password: $test_password
    ).account_updater
  end

  context "when there is no account updater information" do
    let(:test_account) { Vantiv::TestAccount.valid_account }

    it "has no new card token" do
      expect(account_updater_response.new_card_token?).to eq false
    end

    it "has no extended card response" do
      expect(account_updater_response.extended_card_response?).to eq false
    end

    it "returns a nil payment_account_id" do
      expect(account_updater_response.payment_account_id).to eq nil
    end

    it "returns a nil card_type" do
      expect(account_updater_response.card_type).to eq nil
    end

    it "returns a nil expiry month" do
      expect(account_updater_response.expiry_month).to eq nil
    end

    it "returns a nil expiry year" do
      expect(account_updater_response.expiry_year).to eq nil
    end

    it "returns a nil extended_card_response_code" do
      expect(account_updater_response.extended_card_response_code).to eq nil
    end

    it "returns a nil extended_card_response_message" do
      expect(account_updater_response.extended_card_response_message).to eq nil
    end
  end

  context "when there is a new card token and no extened card response" do
    let(:test_account) { Vantiv::TestAccount.account_updater }

    it "has a new card token" do
      expect(account_updater_response.new_card_token?).to eq true
    end

    it "has no extended card response" do
      expect(account_updater_response.extended_card_response?).to eq false
    end

    it "returns updated payment_account_id" do
      expect(account_updater_response.payment_account_id).not_to eq nil
      expect(account_updater_response.payment_account_id).not_to eq ""
    end

    it "returns updated card_type" do
      expect(account_updater_response.card_type).to eq "MC"
    end

    it "returns updated expiry month" do
      expect(account_updater_response.expiry_month).to eq "01"
    end

    it "returns updated expiry year" do
      expect(account_updater_response.expiry_year).to eq "15"
    end

    it "enables using the updated payment account id for subsequent transactions" do
      payment_account_id = account_updater_response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah",
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year,
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      )
      expect(auth_response.success?).to eq true
    end

    it "returns a nil extended_card_response_code" do
      expect(account_updater_response.extended_card_response_code).to eq nil
    end

    it "returns a nil extended_card_response_message" do
      expect(account_updater_response.extended_card_response_message).to eq nil
    end
  end

  context "when there is a new token and an extended card response" do
    let(:test_account) { Vantiv::TestAccount.account_updater_account_closed }

    it "has a new card token" do
      expect(account_updater_response.new_card_token?).to eq true
    end

    it "has an extended card response" do
      expect(account_updater_response.extended_card_response?).to eq true
    end

    it "returns updated payment_account_id" do
      expect(account_updater_response.payment_account_id).not_to eq nil
      expect(account_updater_response.payment_account_id).not_to eq ""
    end

    it "returns updated card_type" do
      expect(account_updater_response.card_type).to eq "VI"
    end

    it "returns updated expiry month" do
      expect(account_updater_response.expiry_month).to eq "11"
    end

    it "returns updated expiry year" do
      expect(account_updater_response.expiry_year).to eq "99"
    end

    it "enables using the updated payment account id for subsequent transactions" do
      payment_account_id = account_updater_response.payment_account_id

      auth_response = Vantiv.auth(
        amount: 10000,
        payment_account_id: payment_account_id,
        customer_id: "doesntmatter",
        order_id: "orderblah",
        expiry_month: test_account.expiry_month,
        expiry_year: test_account.expiry_year,
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      )
      expect(auth_response.success?).to eq true
    end

    it "returns an extended card response code" do
      expect(account_updater_response.extended_card_response_code).to eq "501"
    end

    it "returns an extended card response message" do
      expect(account_updater_response.extended_card_response_message).to eq "The account was closed"
    end
  end

  context "when there is an extended card response and no new card token " do
    let(:test_account) { Vantiv::TestAccount.account_updater_contact_cardholder }

    it "has no new card token" do
      expect(account_updater_response.new_card_token?).to eq false
    end

    it "has an extended card response" do
      expect(account_updater_response.extended_card_response?).to eq true
    end

    it "returns a nil payment_account_id" do
      expect(account_updater_response.payment_account_id).to eq nil
    end

    it "returns a nil card_type" do
      expect(account_updater_response.card_type).to eq nil
    end

    it "returns a nil expiry month" do
      expect(account_updater_response.expiry_month).to eq nil
    end

    it "returns a nil expiry year" do
      expect(account_updater_response.expiry_year).to eq nil
    end

    it "returns an extended card response code" do
      expect(account_updater_response.extended_card_response_code).to eq "504"
    end

    it "returns an extended card response message" do
      expect(account_updater_response.extended_card_response_message).to eq "Contact the cardholder for updated information"
    end
  end
end
