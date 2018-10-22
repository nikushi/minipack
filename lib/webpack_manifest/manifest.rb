# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'uri'

module WebpackManifest
  class Manifest
    class MissingEntryError < StandardError; end
    class FileNotFoundError < StandardError; end

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
      u = URI.parse(@path)
      data = nil
      if u.scheme == 'file' || u.path == @path  # file path
        raise(FileNotFoundError, "#{@path}: no such manifest found") unless File.exist?(@path)
        data = File.read(@path)
      else
        # http url
        data = u.read
      end
      JSON.parse(data)
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
