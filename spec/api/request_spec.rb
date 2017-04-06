require 'spec_helper'

describe Vantiv::Api::Request do
  let(:general_response_class) do
    Class.new(Vantiv::Api::Response) do
      def initialize
        @transaction_response_name = "tokenization_response"
      end
    end
  end

  subject(:run_api_request) do
    Vantiv::Api::Request.new(
      endpoint: Vantiv::Api::Endpoints::TOKENIZATION,
      body: Vantiv::Api::RequestBody.for_tokenization(
        paypage_registration_id: "1234",
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      ),
      response_object: general_response_class.new
    ).run
  end

  context "running an API request when authentication fails" do
    before do
      @cached_password = $test_password
      $test_password = 'aerfdds'
    end

    after do
      $test_password = @cached_password
    end

    it "does not raise errors on standard method retrieval" do
      response = run_api_request
      expect(response.message).to eq nil
      expect(response.response_code).to eq nil
      expect(response.transaction_id).to eq nil
    end

    it "returns the API level error message" do
      response = run_api_request
      expect(response.error_message).to eq "API level error"
    end

    it "returns an api level failure" do
      expect(run_api_request.api_level_failure?).to eq true
    end
  end

  context "when Vantiv (conveniently) doesn't send back xml" do
    it "retries the original request" do
      vantiv_responses = [
        double(
          code_type: Net::HTTPOK,
          code: "200",
          body: ""
        ),
        double(
          code_type: Net::HTTPOK,
          code: "200",
          body: '<litleOnlineRequest version="blabla" merchantId="1234567"><authentication><user>apigee</user><password>apigee</password></authentication></litleOnlineRequest>'
        )
      ]
      allow_any_instance_of(Net::HTTP).to receive(:request) { vantiv_responses.shift }
      expect{
        @response = run_api_request
      }.not_to raise_error
      expect(@response.body.version).to eq "blabla"
    end
  end

  it "sets the raw response on the response object" do
    allow_any_instance_of(Net::HTTP)
      .to receive(:request)
        .and_return(double('http response', body: "some body").as_null_object)

    allow_any_instance_of(ResponseBodyRepresenterXml)
      .to receive(:from_xml)

    expect(run_api_request.raw_body).to eq("some body")
  end

  context "when doing an auth with an online payment cryptogram present" do
    before do
      allow(SecureRandom).to receive(:hex).with(12).twice.and_return "123456789"
    end

    let(:online_payment_cryptogram) { "the-online-payment-cryptogram" }

    let(:payment_account_id) { 123456789 }

    let(:request) do
      body = Vantiv::Api::RequestBody.for_auth_or_sale(
        amount: 4224,
        customer_id: "extid123",
        payment_account_id: payment_account_id,
        order_id: "SomeOrder123",
        expiry_month: "8",
        expiry_year: "2018",
        order_source: "applepay",
        online_payment_cryptogram: online_payment_cryptogram,
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      )

      Vantiv::Api::Request.new(
        endpoint: Vantiv::Api::Endpoints::AUTHORIZATION,
        body: body,
        response_object: Vantiv::Api::LiveTransactionResponse.new(:auth)
      )
    end

    it "includes the online payment cryptogram in the request" do
      expected = <<-END.strip
<litleOnlineRequest version="10.5" xmlns="http://www.litle.com/schema" merchantId="1166386">
  <authorization id="123456789" reportGroup="1" customerId="extid123">
    <orderId>SomeOrder123</orderId>
    <amount>4224</amount>
    <orderSource>applepay</orderSource>
    <token>
      <litleToken>#{payment_account_id}</litleToken>
      <expDate>0818</expDate>
    </token>
    <cardholderAuthentication>
      <authenticationValue>#{online_payment_cryptogram}</authenticationValue>
    </cardholderAuthentication>
    <allowPartialAuth>false</allowPartialAuth>
  </authorization>
</litleOnlineRequest>
END
      request.body.authentication = nil # remove authentication credentials
      expect(request.body.to_xml).to eq expected
    end
  end

  context "when doing an auth without an online payment cryptogram" do
    before do
      allow(SecureRandom).to receive(:hex).with(12).once.and_return "123456789"
    end

    let(:request) do
      body = Vantiv::Api::RequestBody.for_auth_or_sale(
        amount: 4224,
        customer_id: "extid123",
        payment_account_id: "paymentacct123",
        order_id: "SomeOrder123",
        expiry_month: "8",
        expiry_year: "2018",
        merchant_id: $test_merchant_id,
        user: $test_user,
        password: $test_password
      )

      Vantiv::Api::Request.new(
        endpoint: Vantiv::Api::Endpoints::AUTHORIZATION,
        body: body,
        response_object: Vantiv::Api::LiveTransactionResponse.new(:auth)
      )
    end

    it "does not include the online payment cryptogram in the request" do
      expected = <<-END.strip
<litleOnlineRequest version="10.5" xmlns="http://www.litle.com/schema" merchantId="1166386">
  <authorization id="123456789" reportGroup="1" customerId="extid123">
    <orderId>SomeOrder123</orderId>
    <amount>4224</amount>
    <orderSource>ecommerce</orderSource>
    <token>
      <litleToken>paymentacct123</litleToken>
      <expDate>0818</expDate>
    </token>
    <allowPartialAuth>false</allowPartialAuth>
  </authorization>
</litleOnlineRequest>
END
      request.body.authentication = nil # remove authentication credentials
      expect(request.body.to_xml).to eq expected
    end
  end

end
