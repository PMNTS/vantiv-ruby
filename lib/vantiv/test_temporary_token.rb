module Vantiv
  class Vantiv::TestTemporaryToken

    def self.valid_temporary_token
      new(
        name: "mocked-valid-temporary-token",
        test_card: TestCard.valid_account
      )
    end

    def self.invalid_account_number
      new(
        name: "mocked-invalid-account-number",
        test_card: TestCard.invalid_account_number
      )
    end

    def self.insufficient_funds
      new(
        name: "mocked-insufficient-funds",
        test_card: TestCard.insufficient_funds
      )
    end

    def self.expired_card
      new(
        name: "mocked-expired-card",
        test_card: TestCard.expired_card
      )
    end

    def self.account_updater
      new(
        name: "mocked-account-updater",
        test_card: TestCard.account_updater
      )
    end

    def self.account_updater_account_closed
      new(
        name: "mocked-account-updater-account-closed",
        test_card: TestCard.account_updater_account_closed
      )
    end

    def self.account_updater_contact_cardholder
      new(
        name: "mocked-account-updater-contact-cardholder",
        test_card: TestCard.account_updater_contact_cardholder
      )
    end

    def self.expired_temporary_token
      new(
        name: "RGFQNCt6U1d1M21SeVByVTM4dHlHb1FsVkUrSmpnWXhNY0o5UkMzRlZFanZiUHVnYjN1enJXbG1WSDF4aXlNcA==",
        test_card: nil
      )
    end

    def self.invalid_temporary_token
      new(
        name: "pDZJcmd1VjNlYXNaSlRMTGpocVZQY1NWVXE4Z W5UTko4NU9KK3p1L1p1Vzg4YzVPQVlSUHNITG1 JN2I0NzlyTg==",
        test_card: nil
      )
    end

    def self.all
      [
        valid_temporary_token,
        invalid_account_number,
        insufficient_funds,
        expired_card,
        account_updater,
        account_updater_account_closed,
        account_updater_contact_cardholder,
        expired_temporary_token,
        invalid_temporary_token
      ]
    end

    attr_reader :name, :test_card

    def initialize(name:, test_card:)
      @name = name
      @test_card = test_card
    end
  end
end
