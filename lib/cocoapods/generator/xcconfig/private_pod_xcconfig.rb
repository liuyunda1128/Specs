module Pod
  module Generator

    #
    class PrivatePodXCConfig < XCConfig

      # Generates the xcconfig for the aggregate_target.
      #
      # @note   The private xcconfig file for a spec target includes the public
      #         namespaced xcconfig file and merges the configuration values
      #         with the default private configuration values.
      #
      # @return [Xcodeproj::Config]
      #
      def generate
        ld_flags = '-ObjC'
        if aggregate_target.consumer.requires_arc?
          ld_flags << ' -fobjc-arc'
        end

        config = {
          'ALWAYS_SEARCH_USER_PATHS'     => 'YES',
          'OTHER_LDFLAGS'                => ld_flags,
          'PODS_ROOT'                    => '${SRCROOT}',
          'HEADER_SEARCH_PATHS'          => quote(aggregate_target.build_headers.search_paths) + ' ' + quote(sandbox.public_headers.search_paths),
          'GCC_PREPROCESSOR_DEFINITIONS' => 'COCOAPODS=1',
          # 'USE_HEADERMAP'                => 'NO'
        }

        consumer_xcconfig(aggregate_target.consumer).to_hash.each do |k, v|
          prefixed_key = aggregate_target.xcconfig_prefix + k
          config[k] = "#{config[k]} ${#{prefixed_key}}"
        end

        @xcconfig = Xcodeproj::Config.new(config)
        @xcconfig.includes = [aggregate_target.name]
        @xcconfig
      end

      #-----------------------------------------------------------------------#

    end
  end
end
