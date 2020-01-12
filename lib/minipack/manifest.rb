# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'uri'

module Minipack
  class Manifest
    # A class that represents a single entry in a manifest
    class Entry
      attr_reader :path, :integrity

      # @param [String] path single path of a single entry
      # @param [String,nil] integrity optional value for subresource integrity of script tags
      def initialize(path, integrity: nil)
        @path = path
        @integrity = integrity
      end

      def ==(other)
        @path == other.path && @integrity == other.integrity
      end
    end

    # A class that represents a group of chunked entries in a manifest
    class ChunkGroup
      attr_reader :entries

      # @param [Array<Minipack::Manifest::Entry>] entries paths of chunked group
      def initialize(entries)
        @entries = entries.map do |entry|
          if entry.is_a?(String)
            Entry.new(entry)
          else
            Entry.new(entry['src'], integrity: entry['integrity'])
          end
        end
      end

      def ==(other)
        @entries == other.entries
      end
    end

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
      paths = data['entrypoints']&.dig(manifest_pack_name, manifest_pack_type) || handle_missing_entry(name)

      entries = data['entrypoints']&.dig(manifest_pack_name, manifest_pack_type).map do |source|
        entry_from_source(source) || handle_missing_entry(name)
      end

      ChunkGroup.new(entries)
    end

    def entry_from_source(source)
      data.find { |_, entry| entry.is_a?(String) ? entry == source : entry['src'] == source }.second
    end

    def lookup!(name)
      find(name) || handle_missing_entry(name)
    end

    # Find an entry by it's name
    #
    # @param [Symbol] name entry name
    # @return [Minipack::Entry]
    def find(name)
      path = data[name.to_s] || return
      if path.is_a? Hash
        integrity = path['integrity']
        path = path['src']
      end
      Entry.new(path, integrity: integrity)
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

