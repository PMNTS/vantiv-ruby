require 'pry'
require 'json'
require 'net/http'
require 'representable/xml'
require 'monkey_patches/representable/xml'
require 'vantiv/api'
require 'vantiv/test_card'
require 'vantiv/test_temporary_token'
require 'vantiv/environment'
require 'vantiv/mocked_sandbox'
require 'vantiv/paypage'

module Vantiv
  def self.tokenize(temporary_token:, merchant_id:, user:, password:)
    if temporary_token == "" or temporary_token == nil
      raise ArgumentError.new("Blank temporary token (PaypageRegistrationID): \n
                               Check that paypage error handling is implemented correctly.")
    end

    body = Api::RequestBody.for_tokenization(
      paypage_registration_id: temporary_token,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::TOKENIZATION,
      body: body,
      response_object: Api::TokenizationResponse.new
    ).run
  end

  def self.tokenize_by_direct_post(card_number:, expiry_month:, expiry_year:, cvv:,
    merchant_id:, user:, password:)
    body = Api::RequestBody.for_direct_post_tokenization(
      card_number: card_number,
      expiry_month: expiry_month,
      expiry_year: expiry_year,
      cvv: cvv,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::TOKENIZATION,
      body: body,
      response_object: Api::TokenizationResponse.new
    ).run
  end

  def self.auth(amount:, payment_account_id:, customer_id:, order_id:, expiry_month:, expiry_year:,
    order_source: Vantiv.default_order_source, use_temporarily_stored_security_code: false,
    online_payment_cryptogram: nil, original_network_transaction_id: nil, processing_type: nil,
    original_transaction_amount: nil, merchant_id:, user:, password:)

    # RE use_temporarily_stored_security_code
    # From XML Docs:
    # When you submit the CVV2/CVC2/CID in a registerTokenRequest, the platform encrypts
    # and stores the value on a temporary basis for later use in a tokenized Auth/Sale
    # transaction submitted without the value. To use the store value when
    # submitting an Auth/Sale transaction, set the cardValidationNum value to 000.

    cvv = use_temporarily_stored_security_code ? '000' : nil

    body = Api::RequestBody.for_auth_or_sale(
      amount: amount,
      order_id: order_id,
      customer_id: customer_id,
      payment_account_id: payment_account_id,
      expiry_month: expiry_month,
      expiry_year: expiry_year,
      cvv: cvv,
      order_source: order_source,
      online_payment_cryptogram: online_payment_cryptogram,
      original_network_transaction_id: original_network_transaction_id,
      original_transaction_amount: original_transaction_amount,
      processing_type: processing_type,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::AUTHORIZATION,
      body: body,
      response_object: Api::LiveTransactionResponse.new(:auth)
    ).run
  end

  def self.auth_reversal(transaction_id:, amount: nil, merchant_id:, user:, password:)
    body = Api::RequestBody.for_auth_reversal(
      transaction_id: transaction_id,
      amount: amount,
      merchant_id: merchant_id,
      user: user,
      password: password
    )

    Api::Request.new(
      endpoint: Api::Endpoints::AUTH_REVERSAL,
      body: body,
      response_object: Api::TiedTransactionResponse.new(:auth_reversal)
    ).run
  end

  def self.capture(transaction_id:, amount: nil, merchant_id:, user:, password:)
    body = Api::RequestBody.for_capture(
      transaction_id: transaction_id,
      amount: amount,
      merchant_id: merchant_id,
      user: user,
      password: password
    )

    Api::Request.new(
      endpoint: Api::Endpoints::CAPTURE,
      body: body,
      response_object: Api::TiedTransactionResponse.new(:capture)
    ).run
  end

  def self.auth_capture(amount:, payment_account_id:, customer_id:, order_id:,
      expiry_month:, expiry_year:, order_source: Vantiv.default_order_source,
      online_payment_cryptogram: nil, original_network_transaction_id: nil, processing_type: nil,
      original_transaction_amount: nil, merchant_id:, user:, password:)
    body = Api::RequestBody.for_auth_or_sale(
      amount: amount,
      order_id: order_id,
      customer_id: customer_id,
      payment_account_id: payment_account_id,
      expiry_month: expiry_month,
      expiry_year: expiry_year,
      order_source: order_source,
      online_payment_cryptogram: online_payment_cryptogram,
      original_network_transaction_id: original_network_transaction_id,
      original_transaction_amount: original_transaction_amount,
      processing_type: processing_type,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::SALE,
      body: body,
      response_object: Api::LiveTransactionResponse.new(:sale)
    ).run
  end

  # NOTE: ActiveMerchant's #refund... only for use on a capture or sale it seems
  #       -> 'returns' are refunds too, credits are tied to a sale/capture, returns can be willy nilly
  def self.credit(transaction_id:, amount: nil, merchant_id:, user:, password:)
    body = Api::RequestBody.for_credit(
      amount: amount,
      transaction_id: transaction_id,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::CREDIT,
      body: body,
      response_object: Api::TiedTransactionResponse.new(:credit)
    ).run
  end

  def self.refund(amount:, payment_account_id:, customer_id:, order_id:,
      expiry_month:, expiry_year:, order_source: Vantiv.default_order_source,
      merchant_id:, user:, password:)
    body = Api::RequestBody.for_return(
      amount: amount,
      customer_id: customer_id,
      order_id: order_id,
      payment_account_id: payment_account_id,
      expiry_month: expiry_month,
      expiry_year: expiry_year,
      order_source: order_source,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::RETURN,
      body: body,
      response_object: Api::TiedTransactionResponse.new(:return)
    ).run
  end

  # NOTE: can void credits
  def self.void(transaction_id:, merchant_id:, user:, password:)
    body = Api::RequestBody.for_void(
      transaction_id: transaction_id,
      merchant_id: merchant_id,
      user: user,
      password: password
    )
    Api::Request.new(
      endpoint: Api::Endpoints::VOID,
      body: body,
      response_object: Api::TiedTransactionResponse.new(:void)
    ).run
  end

  def self.configure
    yield self
  end

  class << self
    %i[ environment default_report_group
        default_order_source paypage_id ].freeze.each do |config_var|

      define_method(config_var) do
        instance_variable_get("@#{config_var}").tap do |value|
          raise "Missing Vantiv configuration: #{config_var}" unless value
        end
      end

      attr_writer config_var
    end
  end

  def self.root
    File.dirname __dir__
  end
end

