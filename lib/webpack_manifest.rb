# frozen_string_literal: true

module WebpackManifest
  require 'webpack_manifest/manifest'
  require 'webpack_manifest/rails'
  require 'webpack_manifest/rails/file_change_watcher'
  require 'webpack_manifest/rails/command_runner'
  require 'webpack_manifest/rails/railtie'
  require "webpack_manifest/version"
end
