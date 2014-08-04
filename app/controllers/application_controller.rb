class ApplicationController < ActionController::Base
  protect_from_forgery
  def tickets(associated_people,zendeskApi_obj)
    unless associated_people.blank?
      render :json => zendeskApi_obj.get_all_tickets(associated_people).to_json  , :status => 200 and return
    else
      exception_obj = ExceptionMessage.new("Not Found",404,"email address of associated people not found on pipelinedeals")
      render :json => exception_obj.message.to_json and return
    end
  end

end
