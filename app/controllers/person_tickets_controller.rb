require "pipeline_deals"
require "zendesk"
class PersonTicketsController < ApplicationController

  def show
    session[:subdomain] = params[:subdomain]
    person_id = params[:person_id]
    api_key = params[:api_key]
    pipeline_deals_obj = PipelineDeals.new(api_key)
    pipeline_deals_obj.person_id = person_id
    person = pipeline_deals_obj.get_person_details
    if person["status"] == 200
    get_person_tickets(person)
    else
      exception_obj = ExceptionMessage.new(person["message"],person["status"],person["error"])
      render :json => exception_obj.message.to_json and return
    end

  end

  def get_person_tickets(person)
      unless person["result"]["email"].blank?
        authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
        zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
        zendeskApi_obj.person_email = person["result"]["email"]
        person_obj = zendeskApi_obj.get_person_by_email
        unless person_obj["result"]["results"].blank?
          zendesk_user_id = person_obj["result"]["results"][0]["id"]
          zendeskApi_obj.user_id = zendesk_user_id
          tickets = zendeskApi_obj.get_tickets
          render :json => tickets.to_json  , :status => 200 and return
        else
          exception_obj = ExceptionMessage.new("Not Found",404,"person_id #{person_id} not found on zendesk")
          render :json => exception_obj.message.to_json and return
        end

      else
        exception_obj = ExceptionMessage.new("Not Found",404,"email address of person_id #{person_id} not found on pipelinedeals")
        render :json => exception_obj.message.to_json and return

      end
  end

end