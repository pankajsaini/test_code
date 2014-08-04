require "pipeline_deals"
require "zendesk"
class CompanyTicketsController < ApplicationController

  def show
    session[:subdomain] = params[:subdomain]
    company_id = params[:company_id]
    api_key = params[:api_key]

    pipeline_obj = PipelineDeals.new(api_key)
    pipeline_obj.company_id = company_id
    people_associated_company = pipeline_obj.get_company_details

    if people_associated_company["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_company["result"])
      get_company_tickets(associated_people)
    else
      exception_obj = ExceptionMessage.new(people_associated_company["message"],people_associated_company["status"],people_associated_company["error"])
      render :json => exception_obj.message.to_json and return
    end

  end


  def get_company_tickets(associated_people)
    unless associated_people.blank?
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      data_array = []
      associated_people.each {|email|
        zendeskApi_obj.person_email = email
        person_obj = zendeskApi_obj.get_person_by_email
        response = Hash.new
        response["email"]= email
        response["tickets"] =nil
        data_array <<  zendeskApi_obj.get_person_tickets(person_obj,response)
      }
      render :json => data_array.to_json  , :status => 200 and return
    else
      exception_obj = ExceptionMessage.new("Not Found",404,"email address of associated people not found on pipelinedeals")
      render :json => exception_obj.message.to_json and return
    end
  end


end
