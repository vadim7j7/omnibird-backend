# frozen_string_literal: true

module Connections
  module Helpers
    module EmailSenderCategory
      def validate_connection!
        return if connection.email_sender?

        raise Connections::Exceptions::WrongCategoryError, "#{self.class.name} doesn't support #{connection.category}"
      end
    end
  end
end
