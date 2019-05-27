# frozen_string_literal: true

require 'rails'

module Minipack
    class Railtie < ::Rails::Railtie
      initializer "minipack.set_defaults" do
        Minipack::Rails.configuration.root_path = ::Rails.root.to_s
        Minipack::Rails.configuration.base_path = ::Rails.root.to_s
      end
    end
end
