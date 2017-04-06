require 'vantiv'

require 'dotenv'
Dotenv.load
Dir["#{Vantiv.root}/spec/support/**/*.rb"].each {|f| require f}

$test_merchant_id = ENV["MERCHANT_ID"] || '1166386'
$test_user        = ENV["VANTIV_USER"] || 'my-user'
$test_password    = ENV["VANTIV_PASSWORD"] || 'my-password'

def configuration
  Vantiv.configure do |config|
    config.environment          = Vantiv::Environment::PRECERTIFICATION
    config.default_order_source = "ecommerce"
    config.paypage_id           = ENV["PAYPAGE_ID"] || 'PAYPAGE_ID'
    config.default_report_group = '1'
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    configuration
    Vantiv::MockedSandbox.enable_self_mocked_requests!
  end
end
