module Rubee
  module Authorizable
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def authorized?(role, model: nil, role_field: :role)
        return false unless authentificated?
        user = authentificated_user(user_model: model)
        return false unless user
        return false unless model.const_get(:ROLES).keys.map(&:to_sym).include?(role.to_sym)
        
        model.const_get(:ROLES).key(user.send(role_field)).to_sym == role.to_sym
      end
    end

    module ClassMethods
      def authorize(model: nil, response_hash: nil, role_field: :role, **roles)
        @__authorizations ||= {}
        symbolyzed_model_name = model.to_s
        @__authorizations[symbolyzed_model_name] ||= {}
        @__authorizations[symbolyzed_model_name].merge! roles

        @__authorizations[symbolyzed_model_name].each do |role, methods|
          methods = methods.is_a?(Array) ? methods : [methods]
          methods.each do |method|
            around method, ->(controller, &original_action) do
              if controller.send(:authorized?, role, model: model, role_field:)
                original_action.call
              else
                response_object_hash = response_hash || { object: { error: 'Unauthorized' }, type: :json, status: 403 }
                controller.response_with(**response_object_hash)
              end
            end
          end
        end
      end
    end
  end
end
