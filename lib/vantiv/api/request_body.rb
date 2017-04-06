require 'securerandom'

module Vantiv
  module Api
    class Authentication
      attr_reader :user, :password

      def initialize(user:, password:)
        @user     = user
        @password = password
      end
    end

    class RequestBody
      attr_reader :merchant_id, :application_id, :report_group
      attr_accessor :card, :transaction, :payment_account, :address

      attr_accessor :version, :authentication, :xmlns

      def initialize(card: nil, transaction: nil, payment_account: nil, merchant_id: nil, user: nil, password: nil)
        @card = card
        @transaction = transaction
        @payment_account = payment_account

        @merchant_id = merchant_id
        @application_id = SecureRandom.hex(12)
        @report_group = Vantiv.default_report_group

        @authentication = Authentication.new(user: user, password: password)
      end

      def to_json
        ::RequestBodyRepresenter.new(self).to_json
      end

      def to_xml
        ::RequestBodyRepresenterXml.new(self).to_xml
      end

      def self.for_auth_or_sale(amount:, customer_id:, order_id:, payment_account_id:,
          expiry_month:, expiry_year:, cvv: nil, order_source: Vantiv.default_order_source,
          online_payment_cryptogram: nil, original_network_transaction_id: nil,
          processing_type: nil, original_transaction_amount: nil, merchant_id:, user:, password:)

        if online_payment_cryptogram
          cardholder_authentication = CardholderAuthentication.new(
            authentication_value: online_payment_cryptogram
          )
        else
          cardholder_authentication = nil
        end

        transaction = Transaction.new(
          order_id: order_id,
          amount_in_cents: amount,
          customer_id: customer_id,
          order_source: order_source,
          partial_approved_flag: false,
          cardholder_authentication: cardholder_authentication,
          original_network_transaction_id: original_network_transaction_id,
          processing_type: processing_type,
          original_transaction_amount: original_transaction_amount
        )
        card = Card.new(
          expiry_month: expiry_month,
          expiry_year: expiry_year,
          cvv: cvv
        )
        payment_account = PaymentAccount.new(id: payment_account_id)

        new(
          transaction: transaction,
          card: card,
          payment_account: payment_account,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_auth_reversal(transaction_id:, amount: nil, merchant_id:, user:, password:)
        transaction = Transaction.new(id: transaction_id, amount_in_cents: amount)
        new(
          transaction: transaction,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_capture(transaction_id:, amount: nil, merchant_id:, user:, password:)
        transaction = Transaction.new(id: transaction_id, amount_in_cents: amount)
        new(
          transaction: transaction,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_credit(transaction_id:, amount: nil, merchant_id:, user:, password:)
        transaction = Transaction.new(id: transaction_id, amount_in_cents: amount)
        new(
          transaction: transaction,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_return(amount:, customer_id:, order_id:, payment_account_id:,
          expiry_month:, expiry_year:, order_source: Vantiv.default_order_source,
          merchant_id:, user:, password:)
        transaction = Transaction.new(
          order_id: order_id,
          amount_in_cents: amount,
          order_source: order_source,
          customer_id: customer_id
        )
        card = Card.new(
          expiry_month: expiry_month,
          expiry_year: expiry_year
        )
        payment_account = PaymentAccount.new(id: payment_account_id)

        new(
          transaction: transaction,
          card: card,
          payment_account: payment_account,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_tokenization(paypage_registration_id:, merchant_id:, user:, password:)
        card = Card.new(paypage_registration_id: paypage_registration_id)
        new(
          card: card,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_direct_post_tokenization(card_number:, expiry_month:, expiry_year:, cvv:, merchant_id:, user:, password:)
        card = Card.new(
          account_number: card_number,
          expiry_month: expiry_month,
          expiry_year: expiry_year,
          cvv: cvv
        )
        new(
          card: card,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

      def self.for_void(transaction_id:, merchant_id:, user:, password:)
        transaction = Transaction.new(id: transaction_id)
        new(
          transaction: transaction,
          merchant_id: merchant_id,
          user: user,
          password: password
        )
      end

    end
  end
end
