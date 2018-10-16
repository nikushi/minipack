# frozen_string_literal: true

module WebpackManifest
  module Rails
    require 'webpack_manifest/rails/helper'

    class << self
      # TODO: multiple manifest files support
      attr_accessor :manifest
    end
  end
end

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :action_view do
  ::ActionView::Base.send :include, WebpackManifest::Rails::Helper
end
