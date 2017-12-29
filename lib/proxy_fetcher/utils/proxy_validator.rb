# frozen_string_literal: true

module ProxyFetcher
  # Default ProxyFetcher proxy validator that checks either proxy
  # connectable or not. It tries to send HEAD request to default
  # URL to check if proxy can be used (aka connectable?).
  class ProxyValidator
    # Default URL that will be used to check if proxy can be used.
    URL_TO_CHECK = 'https://google.com'.freeze

    def initialize(proxy_addr, proxy_port)
      uri = URI.parse(URL_TO_CHECK)
      @http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port.to_i)

      return unless uri.is_a?(URI::HTTPS)

      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def connectable?
      @http.open_timeout = ProxyFetcher.config.timeout
      @http.read_timeout = ProxyFetcher.config.timeout

      @http.start { |connection| return true if connection.request_head('/') }

      false
    rescue StandardError
      false
    end

    class << self
      def connectable?(proxy_addr, proxy_port)
        new(proxy_addr, proxy_port).connectable?
      end
    end
  end
end
