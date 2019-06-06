# frozen_string_literal: true

module Minipack
    # 1-level or 2-levels configuration system. With the typical single site usecase,
    # only the root instance exists as a singleton. If you manage more then one site,
    # each configuration is stored at the 2nd level of the configuration tree.
    class Configuration
      class Collection
        include Enumerable
        class NotFoundError < StandardError; end

        def initialize(configs = [])
          @configs = configs.map(&:id).zip(configs).to_h
        end

        def find(id)
          @configs[id] || raise(NotFoundError, "collection not found by #{id}")
        end

        def each
          @configs.values.each { |c| yield c }
        end
      end

      class Error < StandardError; end

      ROOT_DEFAULT_ID = :''
      BUILD_CACHE_KEY_DEFAULT = [
        'package.json',
        'package-lock.json',
        'yarn.lock',
        'webpack.config.js',
        'webpackfile.js',
        'config/webpack.config.js',
        'config/webpackfile.js',
        'app/javascripts/**/*',
      ].freeze

      class << self
        def config_attr(prop, default: nil)
          define_method(prop) do
            @config.fetch(prop) do
              @parent ? @parent.public_send(prop) : default
            end
          end

          define_method("#{prop}=".to_sym) do |v|
            @config[prop] = v
          end
        end
      end

      # Private
      config_attr :root_path
      config_attr :id, default: ROOT_DEFAULT_ID

      config_attr :cache, default: false

      # The base directory of the frontend.
      config_attr :base_path

      config_attr :manifest

      # The lazy compilation is cached until a file is change under the tracked paths.
      config_attr :build_cache_key, default: BUILD_CACHE_KEY_DEFAULT.dup

      # Let me leave this line for remember the indea of pre build hooks
      # config_attr :pre_build_hooks, default: []

      # The command for bundling assets
      config_attr :build_command, default: 'node_modules/.bin/webpack'

      # Let me leave this line to remember the indea of post build hooks
      # config_attr :post_build_hooks, default: []

      # Let me leave this line to remember the indea of pre pkg install hooks
      # config_attr :pre_pkg_install_hooks, default: []

      # The command for installation of npm packages
      config_attr :pkg_install_command, default: 'npm install'

      # Let me leave this line for remember the indea of post pkg install hooks
      # config_attr :post_install_hooks, default: []

      # Initializes a new instance of Configuration class.
      #
      # @param [Configuration,nil] parent refenrece to the parent configuration instance.
      def initialize(parent = nil)
        @parent = parent
        # Only a root instance can have children, which are sub configurations each site.
        @children = {}
        @config = {}
      end

      # Register a sub configuration with a site name, with a manifest file
      # optionally. You can configure per site.
      #
      # @param [Symbol] id uniq name of the site
      # @param [String] path path of the manifest file
      # @yieldparam [Configuration] config a sub configuration instance is sent to the block
      def add(id, path = nil)
        raise Error, 'Defining a sub configuration under a sub is not allowed' if leaf?

        id = id.to_sym
        config = self.class.new(self)
        config.id = id
        config.manifest = path unless path.nil?

        # Link the root to the child
        @children[id] = config

        # The sub configuration can be configured within a block
        yield config if block_given?

        config
      end

      def children
        Collection.new(@children.values)
      end

      # Return scoped leaf nodes in self and children. This method is useful
      # to get the concrete(enabled, or active) configuration instances.
      # Each leaf inherit parameters from parent, so leaves always become
      # active.
      def leaves
        col = @children.empty? ? [self] : @children.values
        Collection.new(col)
      end

      # TODO: This will be moved to Minipack.manifests in the future.
      def manifests
        raise Error, 'Calling #manifests is only allowed from a root' unless root?

        repo = ManifestRepository.new
        #  Determine if a single manifest mode or multiple manifests(multiple site) mode
        targets =  @children.empty? ? [self] : @children.values
        targets.each do |config|
          # Skip sites that a manifest file is not configured
          next if config.manifest.nil?

          repo.add(config.id, config.manifest, cache: config.cache)
        end
        repo
      end

      # Resolve base_path as an absolute path
      #
      # @return [String]
      def resolved_base_path
        File.expand_path(base_path || '.', root_path)
      end

      # Resolve build_cache_key as absolute paths
      #
      # @return [Array<String>]
      def resolved_build_cache_key
        base = resolved_base_path
        build_cache_key.map { |path| File.expand_path(path, base) }
      end

      # @return [String]
      def cache_path
        File.join(root_path, 'tmp', 'cache', 'minipack')
      end

      private

      def root?
        @parent.nil?
      end

      def leaf?
        !root?
      end
    end
 end
