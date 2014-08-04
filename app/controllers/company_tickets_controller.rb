require "pipeline_deals"
require "zendesk"
class CompanyTicketsController < ApplicationController

  def show
    session[:subdomain] = params[:subdomain]
    company_id = params[:company_id]
    api_key = params[:api_key]
    pipeline_obj = PipelineDeals.new(api_key)
    get_people_associated_company(pipeline_obj,company_id)
  end

  def get_people_associated_company(pipeline_obj,company_id)
    pipeline_obj.company_id = company_id
    people_associated_company = pipeline_obj.get_company_details
    if people_associated_company["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_company["result"])
      unless associated_people.blank?
        authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
        associated_people_tickets(authentication_key,associated_people)
      else
         render :json => exception_message("Not Found",404,"email address not found").to_json and return
      end
    else
      render :json => exception_message(people_associated_company["message"],people_associated_company["status"],people_associated_company["error"]).to_json and return
    end
  end

  def associated_people_tickets(authentication_key,associated_people)
    if authentication_key
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      render :json => tickets(associated_people,zendeskApi_obj).to_json  , :status => 200 and return
    else
      render :json => exception_message('Not Found',404,"Access Token not found").to_json and return
    end
  end

end
