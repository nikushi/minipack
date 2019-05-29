# frozen_string_literal: true

require "digest/sha1"
require 'pathname'

module Minipack
    class FileChangeWatcher
      # @param [Array<Pathname>] watched_paths
      # @param [Pathname] digest_store_path
      def initialize(watched_paths, digest_store_path)
        @watched_paths = watched_paths
        @digest_store_path = Pathname.new(digest_store_path)
      end

      # Returns true if all watched files are up to date
      def fresh?
        watched_files_digest == last_stored_digest
      end

      # Returns true if the watched files are out of date
      def stale?
        !fresh?
      end

      def record_digest
        @digest_store_path.dirname.mkpath
        @digest_store_path.write(watched_files_digest)
      end

      private

      def last_stored_digest
        @digest_store_path.read if @digest_store_path.exist?
      rescue Errno::ENOENT, Errno::ENOTDIR
      end

      def watched_files_digest
        files = Dir[*@watched_paths].reject { |f| File.directory?(f) }
        file_ids = files.sort.map { |f| "#{File.basename(f)}/#{Digest::SHA1.file(f).hexdigest}" }
        Digest::SHA1.hexdigest(file_ids.join("/"))
      end
    end
end
 
