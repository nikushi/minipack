# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    logger = Logger.new(STDOUT).tap do |l|
      l.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    end
    Minipack.install(logger: logger)
    Minipack.build(logger: logger)
  end
end
