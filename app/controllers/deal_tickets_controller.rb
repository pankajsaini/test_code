require "pipeline_deals"
require "zendesk"

class DealTicketsController < ApplicationController
  before_filter :only => [:show] do |c| c.required_parameters params[:subdomain],params[:deal_id],params[:api_key] end

  def show
    deal_id = params[:deal_id]
    api_key = params[:api_key]
    pipeline_obj = PipelineDeals.new(api_key)
    pipeline_obj.deal_id = deal_id
    pipeline_people_associated_with_deal(pipeline_obj)
  end

  #method for getting people emails associated with deal
  def pipeline_people_associated_with_deal(pipeline_obj)
    people_associated_deal = pipeline_obj.get_deal_details
    if people_associated_deal["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_deal["result"])
      people_tickets_on_zendesk(associated_people)
    else
      render :json => exception_message(people_associated_deal["message"],people_associated_deal["status"],people_associated_deal["error"]).to_json, :status=> people_associated_deal["status"] and return
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
  #method for getting tickets details
  def get_people_tickets(authentication_key,associated_people)
    if authentication_key
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      render :json => zendeskApi_obj.get_all_tickets(associated_people).to_json  , :status => 200 and return
    else
      render :json => exception_message('Unauthorized',401,"Access Token not found").to_json, :status => 401 and return
    end
  end

end
