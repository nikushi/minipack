# frozen_string_literal: true

module WebpackManifest
  module Rails
    require 'webpack_manifest/rails/configuration'
    require 'webpack_manifest/rails/helper'
    require 'webpack_manifest/rails/manifest_repository'

    class << self
      # TODO: multiple manifest files support
      attr_accessor :manifest

      def configuration(&block)
        @configuration ||= Configuration.new
        yield @configuration if block_given?
        @configuration
      end
    end
  end
end

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, WebpackManifest::Rails::Helper
end
