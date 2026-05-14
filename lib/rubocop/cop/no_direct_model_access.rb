# frozen_string_literal: true

return unless defined?(RuboCop)

module RuboCop
  module Cop
    module ContentStudio
      # Prevents direct access to BlackboardLMS ActiveRecord models from within
      # the Content Studio engine. All data must flow through ContentStudio::ApiClient.
      #
      # @example
      #   # bad
      #   User.find(id)
      #   Course.where(published: true)
      #
      #   # good
      #   ContentStudio::ApiClient.current_user
      #   ContentStudio::ApiClient.list_courses
      class NoDirectModelAccess < RuboCop::Cop::Base
        MSG = 'Direct access to BlackboardLMS model `%<model>s` is not allowed in Content Studio. ' \
              'Use ContentStudio::ApiClient instead.'

        BLACKBOARD_MODELS = Dir[
          File.expand_path('../../../app/models/*.rb', __dir__)
        ].to_set { |f| File.basename(f, '.rb').camelize }.freeze

        def on_const(node)
          return unless in_content_studio?(processed_source.path)
          return unless blackboard_model?(node)
          return if inside_content_studio_namespace?(node)

          add_offense(node, message: format(MSG, model: node.const_name))
        end

        private

        def in_content_studio?(path)
          path.to_s.include?('engines/content_studio/')
        end

        def blackboard_model?(node)
          BLACKBOARD_MODELS.include?(node.const_name) && node.namespace.nil?
        end

        # Returns true if the constant appears inside `module ContentStudio`,
        # meaning bare `User` resolves to ContentStudio::User (a local struct),
        # not the BlackboardLMS ActiveRecord model.
        def inside_content_studio_namespace?(node)
          node.each_ancestor(:module).any? do |mod|
            mod.identifier.const_name == 'ContentStudio'
          end
        end
      end
    end
  end
end
