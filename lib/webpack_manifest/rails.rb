# frozen_string_literal: true

require 'logger'

module WebpackManifest
  module Rails
    INSTALLER_WATCHED_PATHS = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

    require 'webpack_manifest/rails/configuration'
    require 'webpack_manifest/rails/helper'
    require 'webpack_manifest/rails/manifest_repository'
    require 'webpack_manifest/rails/file_change_watcher'
    require 'webpack_manifest/rails/command_runner'
    require 'webpack_manifest/rails/railtie'

    class << self
      def configuration(&block)
        @configuration ||= Configuration.new
        yield @configuration if block_given?
        @configuration
      end
      attr_writer :configuration

      def build(logger: nil)
        logger ||= Logger.new(STDOUT).tap do |l|
          l.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
        end
        configuration.leaves.each do |c|
          # Install
          installer_watched_paths = INSTALLER_WATCHED_PATHS.map { |f| File.expand_path(f, c.resolved_base_path) }
          installer_watcher = FileChangeWatcher.new(installer_watched_paths, File.join(c.cache_path, "last-installation-digest-#{::Rails.env}"))
          CommandRunner.new(
            {},
            c.install_command,
            chdir: c.resolved_base_path,
            logger: logger,
            watcher: installer_watcher,
          ).run!
          # Build
          build_watcher = FileChangeWatcher.new(c.resolved_watched_paths, File.join(c.cache_path, "last-build-digest-#{::Rails.env}"))
          CommandRunner.new(
            {},
            c.build_command,
            chdir: c.resolved_base_path,
            logger: logger,
            watcher: build_watcher,
          ).run!
        end
      end
    end
  end
end

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, WebpackManifest::Rails::Helper
end
