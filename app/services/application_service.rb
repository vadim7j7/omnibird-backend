# frozen_string_literal: true

class ApplicationService
  attr_reader :result, :status, :params

  def initialize(params: {})
    @params = params

    @result = {}
    @status = true
  end

  def call
    call!
  rescue StandardError
    @status = false
  end

  def call!
    raise NotImplementedError
  end
end
