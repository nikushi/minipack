# frozen_string_literal: true

module Minipack
  # @deprecated
  module Rails
    # To make test green.
    # TODO: Remove them
    Configuration = Minipack::Configuration
    Helper = Minipack::Helper
    ManifestRepository = Minipack::ManifestRepository
    FileChangeWatcher = Minipack::FileChangeWatcher
    CommandRunner = Minipack::CommandRunner
    Railtie = Minipack::Railtie

    class << self
      # @deprecated
      def configuration(&block)
        Minipack.configuration(&block)
      end

      # @deprecated
      def configuration=(c)
        Minipack.configuration = c
      end
    end
  end
end
