# frozen_string_literal: true

module Minipack
  module Commands
    class Base
      class << self
        def call(**args)
          new(**args).call
        end
      end
    end
  end
end
