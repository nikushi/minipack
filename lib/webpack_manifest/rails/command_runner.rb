# frozen_string_literal: true

require 'logger'
require 'open3'

module WebpackManifest
  module Rails
    class CommandRunner
      class UnsuccessfulError < StandardError; end

      def initialize(env, command, chdir: Dir.getwd, logger: Logger.new(nil), watcher: nil)
        @env = env
        @command = command
        @chdir = chdir
        @logger = logger
        @watcher = watcher
      end

      def run
        run!
      rescue UnsuccessfulError
        false
      end

      def run!
        return run_command if @watcher.nil?

        if @watcher.stale?
          run_command.tap do |success|
            @watcher.record_digest if success
          end
        else
          true
        end
      end

      private

      def run_command
        @logger.info "Executing #{@command}"

        stdout, stderr, status = Open3.capture3(
          @env,
          @command,
          chdir: @chdir,
        )

        if status.success?
          @logger.info "Executed successfully"
          @logger.error "#{stderr}" unless stderr.empty?
        else
          @logger.error "Failed to execute:\n#{stderr}"
        end

        status.success? || raise(UnsuccessfulError, "Failed to execute #{@command}, exit:#{status.exitstatus}, stdout:#{stdout}, stderr:#{stderr}")
      end
    end
  end
end
 
