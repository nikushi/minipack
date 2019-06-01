# frozen_string_literal: true

require_relative 'base'

module Minipack
  module Commands
    class Build < Base
      def initialize(logger: nil)
        @logger = logger
      end

      def call
        Minipack.configuration.leaves.each do |c|
          # Note: someone wants pre_build hook?
          build(c)
          # Note: someone wants post_build hook?
         end
        true
      end

      private

      def build(c)
        watcher = FileChangeWatcher.new(c.resolved_build_cache_key, File.join(c.cache_path, "last-build-digest-#{c.id}-#{::Rails.env}"))
        CommandRunner.new(
          {},
          c.build_command,
          chdir: c.resolved_base_path,
          logger: @logger,
          watcher: watcher,
        ).run!
      end
    end
  end
end
