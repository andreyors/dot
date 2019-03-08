# frozen_string_literal: true

require "daemons"
require "logger"

require "socket"
require "openssl"

require_relative "../app/tcp_handler"

require_relative "../app/providers/dns_over_tls_provider"
require_relative "../app/providers/cloudflare"
require_relative "../app/providers/quad9"
require_relative "../app/providers/google"

require_relative "../app/listeners/tcp_listener"
require_relative "../app/listeners/udp_listener"
