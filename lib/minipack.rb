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
  require 'minipack/commands/base'
  require 'minipack/commands/build'
  require 'minipack/commands/pkg_install'
  require "minipack/version"

  class << self
    def configuration(&block)
      @configuration ||= Configuration.new
      yield @configuration if block_given?
      @configuration
    end
    attr_writer :configuration
  end
end

require 'active_support/lazy_load_hooks'
ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, Minipack::Helper
end

# To keep backward compatibility
require_relative 'webpack_manifest'
