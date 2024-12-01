# frozen_string_literal: true

module Auth
  module TokenHelpers
    # @param[User] user
    # @return[Hash]
    def issue_access_tokens(user)
      { access_token: JsonWebToken.instance.encode({ id: user.id }) }
    end
  end
end
