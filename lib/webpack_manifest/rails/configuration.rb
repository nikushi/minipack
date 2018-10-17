# frozen_string_literal: true

module WebpackManifest
  module Rails
    class Configuration
      attr_reader :manifests

      def initialize
        # default values
        @cache = false
        @manifests = ManifestRepository.new
      end

      def cache
        @cache
      end

      def cache=(v)
        @manifests.all_manifests.each { |m| m.cache = v }
        @cache = v
      end

      # Register a single manifest as a default.
      def manifest=(path)
        @manifests.default = @manifests.add '', path, cache: @cache
      end

      # Register a manfiest. You can register multiple files by calling `#add`.
      def add(key, path)
        @manifests.add(key, path, cache: @cache)
      end
    end
  end
 end
