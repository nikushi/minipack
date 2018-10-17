# frozen_string_literal: true

require 'json'

module WebpackManifest
  class Manifest
    class MissingEntryError < StandardError; end

    attr_writer :cache

    def initialize(path_or_hash, cache: false)
      @path_or_hash = path_or_hash
      @cache = cache
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

    def path
      @path_or_hash unless @path_or_hash.is_a?(Hash)
    end

    def cache_enabled?
      @cache
    end

    private

    def data
      if cache_enabled?
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
