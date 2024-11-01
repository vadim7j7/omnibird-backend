# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Integrations
        class ConnectedDataEntity < Grape::Entity
          expose(:avatar,     documentation: { type: :string })
          expose(:email,      documentation: { type: :string })
          expose(:first_name, documentation: { type: :string })
          expose(:last_name,  documentation: { type: :string })
        end
      end
    end
  end
end
