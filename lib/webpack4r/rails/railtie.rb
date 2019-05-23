# frozen_string_literal: true

require 'rails'

module Webpack4r
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "webpack4r.set_defaults" do
        Webpack4r::Rails.configuration.root_path = ::Rails.root.to_s
        Webpack4r::Rails.configuration.base_path = ::Rails.root.to_s
      end
    end
  end
end
