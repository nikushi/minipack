# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    logger = Logger.new(STDOUT).tap do |l|
      l.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    end
    Webpack4r::Rails.install(logger: logger)
    Webpack4r::Rails.build(logger: logger)
  end
end
