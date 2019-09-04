# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'uri'

module Minipack
  class Manifest
    class MissingEntryError < StandardError; end
    class FileNotFoundError < StandardError; end

    attr_reader :path
    attr_writer :cache

    def initialize(path, cache: false)
      @path = path.to_s
      @cache = cache
    end

    def lookup_pack_with_chunks!(name, type: nil)
      manifest_pack_type = manifest_type(name, type)
      manifest_pack_name = manifest_name(name, manifest_pack_type)
      find('entrypoints')&.dig(manifest_pack_name, manifest_pack_type) || handle_missing_entry(name)
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
      transform_data(data)
    end

    def transform_data(data)
      JSON.parse(data).each_with_object({}) { |(key, value), obj|
        obj[key] = value.is_a?(String) ? { 'src' => value } : value
      }
    end

    # The `manifest_name` method strips of the file extension of the name, because in the
    # manifest hash the entrypoints are defined by their pack name without the extension.
    # When the user provides a name with a file extension, we want to try to strip it off.
    def manifest_name(name, pack_type)
      return name if File.extname(name.to_s).empty?
      File.basename(name, '.' + pack_type)
    end

    def manifest_type(name, pack_type)
      return File.extname(name)[1..-1] if pack_type.nil?
      pack_type.to_s
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
