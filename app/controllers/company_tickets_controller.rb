require "pipeline_deals"
require "zendesk"
class CompanyTicketsController < ApplicationController

  def show
    session[:subdomain] = params[:subdomain]
    company_id = params[:company_id]
    api_key = params[:api_key]
    pipeline_obj = PipelineDeals.new(api_key)
    people_associated_company = get_people_associated_company(pipeline_obj,api_key,company_id)
    get_all_company_tickets(people_associated_company,pipeline_obj)
  end

  def get_all_company_tickets(people_associated_company,pipeline_obj)
    if people_associated_company["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_company["result"])
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      tickets(associated_people,zendeskApi_obj)
    else
      exception_obj = ExceptionMessage.new(people_associated_company["message"],people_associated_company["status"],people_associated_company["error"])
      render :json => exception_obj.message.to_json and return
    end
  end

 

  def get_people_associated_company(pipeline_obj,api_key,company_id)
    pipeline_obj.company_id = company_id
    return pipeline_obj.get_company_details
  end


end
