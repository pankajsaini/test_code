class ExceptionMessage
  def initialize(message, status, error)
    @message=message
    @status=status
    @error = error
  end

  def message
    response_hash = Hash.new
    response_hash["message"]= @message
    response_hash["status"]= @status
    response_hash["error"]= @error
    return response_hash
  end
end