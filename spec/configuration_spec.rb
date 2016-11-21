require 'spec_helper'

describe "Vantiv configuration" do
  [:merchant_id,
   :default_report_group,
   :default_order_source,
   :paypage_id,
   :user,
   :password
  ].each do |config_var|
    describe "- accessing #{config_var}" do

      it "works" do
        expect(Vantiv.send(:"#{config_var}")).not_to eq nil
        expect(Vantiv.send(:"#{config_var}")).not_to eq ""
      end

      context "when it has not been configured" do
        before do
          @cached_val = Vantiv.send(:"#{config_var}")
          Vantiv.configure do |config|
            config.send(:"#{config_var}=", nil)
          end
        end

        after do
          Vantiv.configure do |config|
            config.send(:"#{config_var}=", @cached_val)
          end
        end

        it "raises an error" do
          expect{ Vantiv.send(:"#{config_var}") }.to raise_error(/missing.*#{config_var}/i)
        end
      end
    end
  end
end
