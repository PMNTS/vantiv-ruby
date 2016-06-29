module Vantiv
  module Paypage
    def self.payframe_js
      if Vantiv::Environment.production?
        "https://request.securepaypage-litle.com/LitlePayPage/js/payframe-client.min.js"
      else
        "https://request-prelive.np-securepaypage-litle.com/LitlePayPage/js/payframe-client.min.js"
      end
    end
  end
end
