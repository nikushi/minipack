# frozen_string_literal: true

require 'logger'

module Minipack
  require 'minipack/manifest'
  require 'minipack/configuration'
  require 'minipack/helper'
  require 'minipack/manifest_repository'
  require 'minipack/file_change_watcher'
  require 'minipack/command_runner'
  require 'minipack/railtie'
  require "minipack/version"

  INSTALLER_WATCHED_PATHS = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

  @after_initialize_hooks ||= []

  class << self
    attr_reader :after_initialize_hooks

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

    def after_initialize(&hook)
      @after_initialize_hooks << hook
    end
  end
end

# To keep backward compatibility
require_relative 'webpack_manifest'

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, Minipack::Helper
end

ActiveSupport.on_load :after_initialize do
  Minipack.after_initialize_hooks.each(&:call)
end
