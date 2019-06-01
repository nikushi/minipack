# frozen_string_literal: true

# @deprecated Use Minipack instead
module WebpackManifest
  module Rails
    class << self
      # @deprecated Use Minipack.configuration API instead
      def configuration(&block)
        ActiveSupport::Deprecation.warn('WebpackManifest::Rails.configuration was deprecated. Use Minipack.configuration instead.')
        Minipack.configuration(&block)
      end

      # @deprecated Use Minipack.configuration= API instead
      def configuration=(c)
        ActiveSupport::Deprecation.warn('WebpackManifest::Rails.configuration= was deprecated. Use Minipack.configuration= instead.')
        Minipack.configuration = c
      end
    end
  end
end
