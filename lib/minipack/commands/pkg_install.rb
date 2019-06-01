# frozen_string_literal: true

module Minipack
  module Commands
    class PkgInstall < Base
      PKG_INSTALL_CACHE_KEY = ['package.json', 'package-lock.json', 'yarn.lock'].freeze

      def initialize(logger: nil)
        @logger = logger
      end

      def call
        Minipack.configuration.leaves.each do |c|
          # Note: someone wants pre_pkg_install hook?
          pkg_install(c)
          # Note: someone wants post_pkg_install hook?
         end
        true
      end

      private

      def pkg_install(c)
        pkg_install_cache_key = PKG_INSTALL_CACHE_KEY.map { |f| File.expand_path(f, c.resolved_base_path) }
        watcher = FileChangeWatcher.new(pkg_install_cache_key, File.join(c.cache_path, "last-installation-digest-#{c.id}-#{::Rails.env}"))
        CommandRunner.new(
          {},
          c.pkg_install_command,
          chdir: c.resolved_base_path,
          logger: @logger,
          watcher: watcher,
        ).run!
      end
    end
  end
end
