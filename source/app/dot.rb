# frozen_string_literal: true

require_relative "../config/app"

LOG = Logger.new(STDOUT).tap do |logger|
  logger.level = Logger::DEBUG
  logger.progname = "dot"
  logger.datetime_format = "%Y-%m-%d %H:%M:%S%z "
end

TCPListener.new(TCPHandler.new(Google.new)).run
UDPListener.new(TCPHandler.new(Quad9.new)).run

loop do
  sleep(0.5)
end
