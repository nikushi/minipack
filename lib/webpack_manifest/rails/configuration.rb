# frozen_string_literal: true

module WebpackManifest
  module Rails
    # 1-level or 2-levels configuration system. With the typical single site usecase,
    # only the root instance exists as a singleton. If you manage more then one site,
    # each configuration is stored at the 2nd level of the configuration tree.
    class Configuration
      class Error < StandardError; end

      ROOT_DEFAULT_ID = :''

      class << self
        def config_attr(prop)
          define_method(prop) do
            @config.fetch(prop, @parent&.public_send(prop))
          end

          define_method("#{prop}=".to_sym) do |v|
            @config[prop] = v
          end
        end
      end

      config_attr :root_path

      config_attr :id

      config_attr :cache

      config_attr :manifest

      # Initializes a new instance of Configuration class.
      #
      # @param [Configuration,nil] parent refenrece to the parent configuration instance.
      def initialize(parent = nil)
        @parent = parent
        # Only a root instance can have children, which are sub configurations each site.
        @children = {}
        @config = {}

        # If self is a configuration for a specific site, the getting attrs
        # not being configured are delegated to the root configuration, so
        # only root configuration object can have default values.
        reset_defaults! if root?
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

      # Lookup a sub configuration by it's name
      #
      # @param [Symbol] id
      # @return [Configuration] a sub configuration
      def sub(id)
        @children[id]
      end

      # TODO: This will be moved to WebpackManifest::Rails.manifests in the future.
      def manifests
        raise Error, 'Calling #manifests is only allowed from a root' unless root?

        repo = ManifestRepository.new
        #  Determine if a single manifest mode or multiple manifests(multiple site) mode
        targets =  @children.empty? ? [self] : @children.values
        targets.each do |config|
          repo.add(config.id, config.manifest, cache: config.cache)
        end
        repo
      end

      private

      def reset_defaults!
        @config = {
          id: ROOT_DEFAULT_ID,
          cache: false,
        }
      end

      def root?
        @parent.nil?
      end

      def leaf?
        !root?
      end

      def cache_path
        root_path.join('tmp', 'cache', 'webpack_manifest')
      end
    end
  end
 end
