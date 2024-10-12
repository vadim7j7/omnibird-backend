class ApplicationService
  attr_reader :result, :status

  def initialize(params: {})
    @params = params

    @result = {}
    @status = true
  end

  def call
    call!
  rescue StandardError
    # skip
  end

  def call!
    raise NotImplementedError
  end
end
