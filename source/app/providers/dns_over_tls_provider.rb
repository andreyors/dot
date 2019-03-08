# frozen_string_literal: true

class DNSOverTLSProvider
  def ip
    raise NotImplementedError
  end

  def port
    853
  end
end
