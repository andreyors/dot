# frozen_string_literal: true

class TCPListener
  attr_accessor :host, :port, :handler

  def initialize(handler = nil, host = "0.0.0.0", port = 8053)
    self.host = host
    self.port = port

    handler ||= TCPHandler.new(Cloudflare.new)
    self.handler = handler
  end

  def run
    server = Socket.pack_sockaddr_in(port, host)

    tcp_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    tcp_socket.setsockopt(:SOCKET, :REUSEADDR, 1)

    tcp_socket.bind(server)
    tcp_socket.listen(Socket::SOMAXCONN)

    loop do
      Thread.new(tcp_socket.accept) do |conn, _|
        data = conn.readpartial(1024)

        data = handler.process(data)
        conn.write(data)

        conn&.close
      end

      sleep(0.5)
    end
  ensure
    tcp_socket&.close
  end
end
