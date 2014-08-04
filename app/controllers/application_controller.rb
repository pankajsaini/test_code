class ApplicationController < ActionController::Base
  protect_from_forgery
  def tickets(associated_people,zendeskApi_obj)
    unless associated_people.blank?
      return zendeskApi_obj.get_all_tickets(associated_people)
    else
      render :json => exception_message("Not Found",404,"email address of associated people not found on pipelinedeals").to_json and return
    end
  end

  def exception_message(mes,code,des)
    exception_obj = ExceptionMessage.new(mes,code,des)
    return exception_obj.message
  end

end
