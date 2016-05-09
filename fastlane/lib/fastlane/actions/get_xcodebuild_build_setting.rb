module Fastlane
  module Actions
    module SharedValues
      GET_XCODEBUILD_BUILD_SETTING_LAST_VALUE = :GET_XCODEBUILD_BUILD_SETTING_LAST_VALUE
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/fastlane/fastlane/tree/master/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class GetXcodebuildBuildSettingAction < Action
      def self.run(params)

        xcode_proj_path = params[:path_to_xcode_project]
        configuration = params[:configuration]
        key = params[:key]
        UI.message "Getting xcodebuild value for: #{key} #{xcode_proj_path} for #{configuration}"

        xcode_build_command = [
          'xcodebuild',
          '-project',
          xcode_proj_path,
          '-configuration',
          configuration,
          '-showBuildSettings'
        ].join(' ')

        grep_info_plist_file_command = [
          'grep',
          key
        ].join(' ')

        sed_search_for_info_plist_file_command = [
          'sed',
          '-e',
          "'s/#{key} = //'"
        ].join(' ')

        tr_remove_carriage_return_command = [
          'tr',
          '-d',
          "'\n'"
        ].join(' ')

        complete_command = [
          xcode_build_command,
          grep_info_plist_file_command,
          sed_search_for_info_plist_file_command,
          tr_remove_carriage_return_command
        ].join(' | ')

        value = Action.sh(complete_command).lstrip
        if value.length > 0
          return value
        else
          raise "Build setting for #{key} not found!"
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the value for a given key in xcodebuild's -showBuildSettings for Xcode project and configuration"
      end

      def self.details
        "If you need to know a value for a given key (e.g.; INFOPLIST_PATH, GCC_PREPROCESSOR_DEFINITIONS, PRODUCT_NAME) for a particular configuration on a particular project, this action will return it."
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :path_to_xcode_project,
                                     description: "The path to the Xcode Project you'd like the build setting value for",
                                     verify_block: proc do |value|
                                        raise "No path for Xcode Project given, pass using `path_to_xcode_project: 'your_path'`".red unless (value and not value.empty?)
                                     end),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     description: "The configuration of the Xcode Project you'd like the build setting value for",
                                     default_value: "Release",
                                     optional: true),
       FastlaneCore::ConfigItem.new(key: :key,
                                    description: "The key of the Xcode Project you'd like the build setting value for",
                                    verify_block: proc do |value|
                                       raise "No key given for the build setting given, pass using `key: 'key'`".red unless (value and not value.empty?)
                                    end)
      ]
      end

      def self.output
        [
          ['GET_XCODEBUILD_BUILD_SETTING_LAST_VALUE', 'The last build setting queried']
        ]
      end

      def self.return_value
        "The value that corresponds to the xcodebuild -showBuildSettings key."
      end

      def self.authors
        ['jacobvanorder']
      end

      def self.is_supported?(platform)
        platform == :ios #Maybe Mac?
      end
    end
  end
end
