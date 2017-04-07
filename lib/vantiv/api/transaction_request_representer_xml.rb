class TransactionRequestRepresenterXml < Representable::Decorator
  include Representable::XML

  self.representation_wrap = ->(_) { type }

  property :application_id, as: :id, attribute: true
  property :id, as: :litleTxnId
  property :report_group, as: :reportGroup, attribute: true
  property :customer_id, as: :customerId, attribute: true
  property :order_id, as: :orderId
  property :amount_in_cents, as: :amount
  property :order_source, as: :orderSource

  property :address, class: Vantiv::Api::Address do
    self.representation_wrap = :billToAddress

    property :billing_name, as: :name
    property :billing_address_1, as: :addressLine1
    property :billing_address_2, as: :addressLine2
    property :billing_city, as: :city
    property :billing_state, as: :state
    property :billing_zipcode, as: :zip
    property :billing_country, as: :country
  end

  property :card, class: Vantiv::Api::Card, if: ->(_) { type != :registerTokenRequest && (card && !card.paypage_registration_id) } do
    self.representation_wrap = ->(_) { !!payment_account_id ? :token : :card }

    property :type
    property :card_number, as: :number
    property :account_number, as: :number
    property :payment_account_id, as: :litleToken
    property :expDate,
             getter: ->(represented:, **) { represented.expiry_month.to_s + represented.expiry_year.to_s },
             if: ->(_) { expiry_month && expiry_year }
    property :cvv, as: :cardValidationNum
  end

  property :accountNumber,
           if: ->(_) { type == :registerTokenRequest },
           getter: ->(represented:, **) { represented.card && represented.card.account_number }

  property :cardValidationNum,
           if: ->(_) { type == :registerTokenRequest },
           getter: ->(represented:, **) { represented.card && represented.card.cvv }

  property :paypageRegistrationId,
           getter: ->(represented:, **) { represented.card && represented.card.paypage_registration_id }

  property :cardholder_authentication, class: Vantiv::Api::CardholderAuthentication do
    self.representation_wrap = :cardholderAuthentication

    property :authentication_value, as: :authenticationValue
  end

  property :partial_approved_flag, as: :allowPartialAuth

  property :processing_type, as: :processingType
  property :original_network_transaction_id, as: :originalNetworkTransactionId
  property :original_transaction_amount, as: :originalTransactionAmount
end
