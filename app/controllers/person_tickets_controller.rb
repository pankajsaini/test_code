require "pipeline_deals"
require "zendesk"
class PersonTicketsController < ApplicationController
  before_filter :only => [:show] do |c| c.required_parameters params[:subdomain],params[:person_id],params[:api_key] end
  def show
    person_id = params[:person_id]
    api_key = params[:api_key]
    pipeline_person_details(api_key,person_id)
  end

  #method for getting email address of pipeline user
  def pipeline_person_details(api_key,person_id)
    pipeline_deals_obj = PipelineDeals.new(api_key)
    pipeline_deals_obj.person_id = person_id
    person =  pipeline_deals_obj.get_person_details
    if person["status"] == 200
      person_tickets_on_zendesk(person["result"]["email"])
    else
      render :json => exception_message(person["message"],person["status"],person["error"]).to_json, :status=>person["status"] and return
    end
  end

  def person_tickets_on_zendesk(person_email)
    if person_email
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      person_tickets(authentication_key,person_email)
    else
      render :json => exception_message("Not Found",404,"email address not found on pipelinedeals").to_json, :status=>404   and return
    end
  end

  #method for getting zendesk user
  def person_tickets(authentication_key,person_email)
    if authentication_key
      zendesk_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      zendesk_obj.person_email = person_email
      tickets(zendesk_obj)
    else
      render :json => exception_message('Unauthorized',401,"Access Token not found").to_json, :status => 401 and return
    end
  end

  #method for getting person tickets
  def tickets(zendesk_obj)
    person_obj = zendesk_obj.get_person_by_email
    unless person_obj["result"]["results"].blank?
      zendesk_obj.user_id = person_obj["result"]["results"][0]["id"]
      render :json => zendesk_obj.get_tickets_by_api.to_json, :status => 200 and return
    else
      render :json => exception_message("Not Found",404,"email address not found").to_json, :status=>404   and return
    end
  end

end
