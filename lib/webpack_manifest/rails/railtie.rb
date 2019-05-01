# frozen_string_literal: true

require 'rails'

module WebpackManifest
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "webpack_manifest.set_root_path" do
        WebpackManifest::Rails.configuration.root_path = ::Rails.root
      end
    end
  end
end
