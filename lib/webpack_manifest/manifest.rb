# frozen_string_literal: true

require 'json'

module WebpackManifest
  class Manifest
    class MissingEntryError < StandardError; end

    attr_reader :path
    attr_writer :cache

    def initialize(path, cache: false)
      @path = path
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
      File.exist?(@path) ? JSON.parse(File.read(@path)) : {}
    end

    def handle_missing_entry(name)
      raise MissingEntryError, <<~MSG
        Can not find #{name} in #{@path}.
        Your manifest contains:
        #{JSON.pretty_generate(@data)}
      MSG
    end
  end
end
