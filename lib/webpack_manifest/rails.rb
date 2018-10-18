# frozen_string_literal: true

module WebpackManifest
  module Rails
    require 'webpack_manifest/rails/configuration'
    require 'webpack_manifest/rails/helper'
    require 'webpack_manifest/rails/manifest_repository'

    class << self
      def configuration(&block)
        @configuration ||= Configuration.new
        yield @configuration if block_given?
        @configuration
      end
      attr_writer :configuration
    end
  end
end

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, WebpackManifest::Rails::Helper
end
