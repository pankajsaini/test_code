class ExceptionMessage
  def initialize(message, code, error)
    @message=message
    @code=code
    @error = error
  end

  def message
    response_hash = Hash.new
    response_hash["message"]= @message
    response_hash["code"]= @code
    response_hash["error"]= @error
    return response_hash
  end
end