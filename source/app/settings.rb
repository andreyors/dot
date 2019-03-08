# frozen_string_literal: true

class Settings
  def initialize
    @store = []
    yield self
  end

  def set(key, value)
    @store[key] = value
  end

  def get(key)
    @store[key]
  end
end
