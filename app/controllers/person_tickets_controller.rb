require "pipeline_deals"
require "zendesk"
class PersonTicketsController < ApplicationController

  def show
    session[:subdomain] = params[:subdomain]
    person_id = params[:person_id]
    api_key = params[:api_key]
    person = pipeline_person_details(api_key,person_id)
    if person["status"] == 200
      get_person_tickets(person)
    else
      exception_obj = ExceptionMessage.new(person["message"],person["status"],person["error"])
      render :json => exception_obj.message.to_json and return
    end

  end


  def pipeline_person_details(api_key,person_id)
    pipeline_deals_obj = PipelineDeals.new(api_key)
    pipeline_deals_obj.person_id = person_id
    return pipeline_deals_obj.get_person_details
  end

  def get_person_tickets(person)
    email = person["result"]["email"]
    if email
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      person_tickets_on_zendesk(email,zendeskApi_obj)
    else
      render :json => exception_message("Not Found",404,"email address of person_id #{person_id} not found on pipelinedeals").to_json and return
    end
  end

  def person_tickets_on_zendesk(email,zendeskApi_obj)
    zendeskApi_obj.person_email = email
    person_obj = zendeskApi_obj.get_person_by_email
    tickets(person_obj,zendeskApi_obj)
  end


  def tickets(person_obj,zendeskApi_obj)
    if person_obj["result"]["results"]
      zendesk_user_id = person_obj["result"]["results"][0]["id"]
      zendeskApi_obj.user_id = zendesk_user_id
      tickets = zendeskApi_obj.get_tickets_by_api
      render :json => tickets.to_json  , :status => 200 and return
    else
      render :json => exception_message("Not Found",404,"person_id #{person_id} not found on zendesk").to_json and return
    end
  end


  def exception_message(mes,code,des)
    exception_obj = ExceptionMessage.new(mes,code,des)
    return exception_obj.message
  end

end
