# frozen_string_literal: true

module Internal
  module V1
    module Entities
      class Constants
        FAILURE_PUBLIC = [
          [ 500, 'Server Error',    Entities::ErrorEntity ]
        ]

        FAILURE_READ_DELETE = [
          [ 401, 'Unauthenticated', Entities::ErrorEntity ],
          [ 403, 'Forbidden',       Entities::ErrorEntity ],
          [ 404, 'Not Found',       Entities::ErrorEntity ],
          [ 500, 'Server Error',    Entities::ErrorEntity ]
        ].freeze

        FAILURE_CREATE_UPDATE = [
          [ 401, 'Unauthenticated',      Entities::ErrorEntity ],
          [ 403, 'Forbidden',            Entities::ErrorEntity ],
          [ 404, 'Not Found',            Entities::ErrorEntity ],
          [ 422, 'Unprocessable Entity', Entities::ErrorEntity ],
          [ 500, 'Server Error',         Entities::ErrorEntity ]
        ].freeze
      end
    end
  end
end
