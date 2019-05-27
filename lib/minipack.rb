# frozen_string_literal: true

module Minipack
  require 'minipack/manifest'
  require 'minipack/rails'
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

require_relative 'webpack_manifest'
