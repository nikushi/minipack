# frozen_string_literal: true

require 'logger'

module WebpackManifest::Rails
  module RSpec
    module Compilable
      INSTALLER_WATCHED_PATHS = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

      class << self
        def compile
          logger = Logger.new(STDOUT).tap do |l|
            l.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
          end
          WebpackManifest::Rails.configuration.leaves.each do |c|
            # Install
            installer_watched_paths = INSTALLER_WATCHED_PATHS.map { |f| File.expand_path(f, c.resolved_base_path) }
            installer_watcher = FileChangeWatcher.new(installer_watched_paths, File.join(c.cache_path, "last-installation-digest-#{Rails.env}"))
            CommandRunner.new(
              {},
              c.installer_command,
              chdir: c.resolved_base_path,
              logger: logger,
              watcher: installer_watcher,
            ).run!
            # Compile
            compiler_watcher = FileChangeWatcher.new(c.resolved_watched_paths, File.join(c.cache_path, "last-compilation-digest-#{Rails.env}"))
            CommandRunner.new(
              {},
              c.compiler_command,
              chdir: c.resolved_base_path,
              logger: logger,
              watcher: compiler_watcher,
            ).run!
          end
        end
      end
    end
  end
end
