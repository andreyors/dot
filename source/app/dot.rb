# frozen_string_literal: true

require_relative "../config/app"

App.new do |app|
  app.register -> { TCPListener.new(TCPHandler.new(Google.new)).run }
  app.register -> { UDPListener.new(TCPHandler.new(Quad9.new)).run }

  app.run!
end
