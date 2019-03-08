# frozen_string_literal: true

class App
  attr_accessor :threads

  def initialize
    self.threads = []
    yield self
  end

  def register(proc)
    self.threads << Thread.new { proc.call }
  end

  def run!
    self.threads.each(&:join)

    loop do
      sleep(0.5)
    end
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      logger.level = Logger::DEBUG
      logger.progname = "dot"
      logger.datetime_format = "%Y-%m-%d %H:%M:%S%z "
    end
  end
end
