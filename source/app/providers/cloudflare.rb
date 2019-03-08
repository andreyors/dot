# frozen_string_literal: true

class Cloudflare < DNSOverTLSProvider
  def ip
    "1.1.1.1"
  end
end
