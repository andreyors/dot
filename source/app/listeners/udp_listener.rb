# frozen_string_literal: true

class UDPListener
  attr_accessor :host, :port, :handler

  def initialize(handler = nil, host = "0.0.0.0", port = 8053)
    self.host = host
    self.port = port

    handler ||= TCPHandler.new(Cloudflare.new)
    self.handler = handler
  end

  def run
    server = Socket.pack_sockaddr_in(port, host)

    udp_socket = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
    udp_socket.setsockopt(:SOCKET, :REUSEADDR, 1)

    udp_socket.bind(server)
    
    loop do
      Thread.new(udp_socket.recvfrom(4096)) do |data, client_address|
        response = udp_process(data)

        udp_socket.send(response, 0, client_address)
      end
      
      sleep(0.5)
    end
  ensure
    udp_socket&.close
  end

  def udp_process(data)
    response = handler.process([data.size].pack("n") + data)

    response[2..-1]
  end
end
