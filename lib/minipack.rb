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
  require 'minipack/commands/build'
  require "minipack/version"

  INSTALLER_WATCHED_PATHS = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

  class << self
    def configuration(&block)
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end
    attr_writer :configuration

    def install(logger: nil)
      configuration.leaves.each do |c|
        build_cache_key = INSTALLER_WATCHED_PATHS.map { |f| File.expand_path(f, c.resolved_base_path) }
        watcher = FileChangeWatcher.new(build_cache_key, File.join(c.cache_path, "last-installation-digest-#{c.id}-#{::Rails.env}"))
        CommandRunner.new(
          {},
          c.pkg_install_command,
          chdir: c.resolved_base_path,
          logger: logger,
          watcher: watcher,
        ).run!
      end
    end

    # Find all 'minipack_plugin' files in $LOAD_PATH and load them
    def load_env_plugins

      files = []
      glob = '**/minipack_plugin.rb'
      $LOAD_PATH.each do |load_path|
        globbed = Dir.glob(File.expand_path(glob, load_path))

        globbed.each do |load_path_file|
          files << load_path_file if File.file?(load_path_file)
        end
      end

      load_plugin_files files
    end

    def load_plugins
      load_plugin_files ::Gem.find_latest_files('minipack/**/minipack_plugin', false)
    end

    private

    def load_plugin_files(plugins)
      plugins.each do |plugin|
        begin
          load plugin
        rescue ::Exception => e
          details = "#{plugin.inspect}: #{e.message} (#{e.class})"
          warn "Error loading Minipack plugin #{details}"
        end
      end
    end
  end
end

# To keep backward compatibility
require_relative 'webpack_manifest'

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, Minipack::Helper
end

Minipack.load_env_plugins
Minipack.load_plugins
