# frozen_string_literal: true

require 'json'

module WebpackManifest
  class Manifest
    class MissingEntryError < StandardError; end

    def initialize(path_or_hash, cache: false)
      @path_or_hash = path_or_hash
      @cache_manifest = cache
    end

    def lookup!(name)
      find(name) || handle_missing_entry(name)
    end

    def find(name)
      data[name.to_s]
    end

    def assets
      data.values
    end

    private

    def data
      if @cache_manifest
        @data ||= load_data
      else
        load_data
      end
    end

    def load_data
      return @path_or_hash if @path_or_hash.is_a? Hash
      path = @path_or_hash
      File.exist?(path) ? JSON.parse(File.read(path)) : {}
    end

    def handle_missing_entry(name)
      raise MissingEntryError, <<~MSG
        Can not find #{name} in #{@path_or_hash}.
        Your manifest contains:
        #{JSON.pretty_generate(@data)}
      MSG
    end
  end
end
