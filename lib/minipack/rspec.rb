# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    logger = Logger.new(STDOUT).tap do |l|
      l.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    end
    Minipack::Commands::PkgInstall.call(logger: logger)
    Minipack::Commands::Build.call(logger: logger)
  end
end
