# frozen_string_literal: true

module Minipack
  # @deprecated
  module Rails
    class << self
      # @deprecated
      def configuration(&block)
        Minipack.configuration(&block)
      end

      # @deprecated
      def configuration=(c)
        Minipack.configuration = c
      end
    end
  end
end
