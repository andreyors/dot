# frozen_string_literal: true

class TCPHandler
  attr_accessor :provider

  def initialize(provider = nil)
    raise ArgumentError unless provider.is_a? DNSOverTLSProvider

    self.provider = provider
  end

  def process(data)
    tcp_socket = TCPSocket.open(provider.ip, provider.port)

    OpenSSL::SSL::SSLSocket.new(tcp_socket, ssl_context).tap do |wrapper|
      wrapper.hostname = self.provider.ip
      wrapper.sync_close = true
      wrapper.connect

      wrapper.syswrite(data)
      data = wrapper.sysread(4096)

      wrapper&.sysclose
    end
    tcp_socket&.close

    data
  end

  def ssl_context
    context = OpenSSL::SSL::SSLContext.new

    context.ssl_version = :TLSv1_2

    context.options = options
    context.ciphers = ciphers

    context.ca_path = OpenSSL::X509::DEFAULT_CERT_DIR
    context.ca_file = OpenSSL::X509::DEFAULT_CERT_FILE

    context.verify_hostname = true
    context.verify_mode = OpenSSL::SSL::VERIFY_PEER
    context.verify_depth = 5

    context
  end

  def options
    OpenSSL::SSL::OP_ALL &
      ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS |
      OpenSSL::SSL::OP_NO_TLSv1 |
      OpenSSL::SSL::OP_NO_TLSv1_1 |
      OpenSSL::SSL::OP_NO_SSLv2 |
      OpenSSL::SSL::OP_NO_SSLv3 |
      OpenSSL::SSL::OP_NO_COMPRESSION
  end

  def ciphers
    "DEFAULT:!aNULL:!eNULL:!LOW:!EXPORT:!SSLv2"
  end
end
