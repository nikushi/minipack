# frozen_string_literal: true

module Minipack
  module Rails
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

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, Minipack::Helper
end
