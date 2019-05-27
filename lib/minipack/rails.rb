# frozen_string_literal: true

require 'logger'

module Minipack
  module Rails
    INSTALLER_WATCHED_PATHS = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

    require 'minipack/configuration'
    require 'minipack/helper'
    require 'minipack/manifest_repository'
    require 'minipack/file_change_watcher'
    require 'minipack/command_runner'
    require 'minipack/railtie'

    # To make test green.
    # TODO: Remove them
    Configuration = Minipack::Configuration
    Helper = Minipack::Helper
    ManifestRepository = Minipack::ManifestRepository
    FileChangeWatcher = Minipack::FileChangeWatcher
    CommandRunner = Minipack::CommandRunner
    Railtie = Minipack::Railtie

    class << self
      def configuration(&block)
        @configuration ||= Configuration.new
        yield @configuration if block_given?
        @configuration
      end
      attr_writer :configuration

      def install(logger: nil)
        configuration.leaves.each do |c|
          watched_paths = INSTALLER_WATCHED_PATHS.map { |f| File.expand_path(f, c.resolved_base_path) }
          watcher = FileChangeWatcher.new(watched_paths, File.join(c.cache_path, "last-installation-digest-#{c.id}-#{::Rails.env}"))
          CommandRunner.new(
            {},
            c.install_command,
            chdir: c.resolved_base_path,
            logger: logger,
            watcher: watcher,
          ).run!
        end
      end

      def build(logger: nil)
        configuration.leaves.each do |c|
          watcher = FileChangeWatcher.new(c.resolved_watched_paths, File.join(c.cache_path, "last-build-digest-#{c.id}-#{::Rails.env}"))
          CommandRunner.new(
            {},
            c.build_command,
            chdir: c.resolved_base_path,
            logger: logger,
            watcher: watcher,
          ).run!
        end
      end
    end
  end
end

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, Minipack::Helper
end