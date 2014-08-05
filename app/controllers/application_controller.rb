class ApplicationController < ActionController::Base
  protect_from_forgery

  def exception_message(mes,code,description)
    exception_obj = ExceptionMessage.new(mes,code,description)
    return exception_obj.message
  end

  def required_parameters(subdomain,id,key)
    if subdomain.blank? or id.blank? or key.blank?
      render :json => exception_message('Bad Request',400,'required parameters missing').to_json, :status => 400  and return
    else
      session[:subdomain] = params[:subdomain]
    end
  end

end
