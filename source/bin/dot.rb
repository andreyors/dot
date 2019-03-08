#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/app"

file = File.expand_path("../app/dot.rb", __dir__)
Daemons.run(file)
