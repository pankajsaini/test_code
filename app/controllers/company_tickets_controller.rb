require "pipeline_deals"
require "zendesk"
class CompanyTicketsController < ApplicationController
  before_filter :only => [:show] do |c| c.required_parameters params[:subdomain],params[:company_id],params[:api_key] end

  def show
    company_id = params[:company_id]
    api_key = params[:api_key]
    pipeline_obj = PipelineDeals.new(api_key)
    pipeline_obj.company_id = company_id
    pipeline_people_associated_with_company(pipeline_obj)
  end

  def pipeline_people_associated_with_company(pipeline_obj)
    people_associated_company = pipeline_obj.get_company_details
    if people_associated_company["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_company["result"])
      people_tickets_on_zendesk(associated_people)
    else
      render :json => exception_message(people_associated_company["message"],people_associated_company["status"],people_associated_company["error"]).to_json, :status=> people_associated_company["status"] and return
    end
  end

  def people_tickets_on_zendesk(associated_people)
    unless associated_people.blank?
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      get_people_tickets(authentication_key,associated_people)
    else
      render :json => exception_message("Not Found",404,"email address not found").to_json , :status=> 404 and return
    end
  end

  def get_people_tickets(authentication_key,associated_people)
    if authentication_key
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      render :json => zendeskApi_obj.get_all_tickets(associated_people).to_json  , :status => 200 and return
    else
      render :json => exception_message('Unauthorized',401,"Access Token not found").to_json, :status => 401 and return
    end
  end

end
