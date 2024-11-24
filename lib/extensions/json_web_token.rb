# frozen_string_literal: true

class JsonWebToken
  include Singleton

  ExpiredSignature = Class.new(StandardError)
  DecodeError      = Class.new(StandardError)

  # @param[Hash] payload
  # @param[String] key
  # @param[Integer] exp
  # @param[String] algorithm
  def encode(
    payload,
    key: Rails.application.credentials.secret_key_base,
    exp: ENV.fetch('TOKEN_EXPIRATION_TIME', 3600),
    algorithm: 'HS256'
  )
    payload[:exp] = exp.to_i.seconds.from_now.to_i
    JWT.encode(payload, key, algorithm)
  end

  # @param[String] token
  # @param[String] key
  # @param[String] algorithm
  def decode(token, key: Rails.application.credentials.secret_key_base, algorithm: 'HS256')
    body = JWT.decode(token, key, true, algorithm:)[0]
    ActiveSupport::HashWithIndifferentAccess.new(body).deep_symbolize_keys
  rescue JWT::ExpiredSignature => e
    raise ExpiredSignature, e.message
  rescue JWT::DecodeError, JWT::VerificationError => e
    raise DecodeError, e.message
  end
end
