require "pipeline_deals"
require "zendesk"

class DealTicketsController < ApplicationController
  def show
    session[:subdomain] = params[:subdomain]
    deal_id = params[:deal_id]
    api_key = params[:api_key]
    pipeline_obj = PipelineDeals.new(api_key)
    people_associated_deal = get_people_associated_deal(pipeline_obj,api_key,deal_id)
    get_all_deal_tickets(people_associated_deal,pipeline_obj)
  end


  def get_all_deal_tickets(people_associated_deal,pipeline_obj)
    if people_associated_deal["status"] == 200
      associated_people =  pipeline_obj.get_associated_people(people_associated_deal["result"])
      tickets(associated_people)
    else
      exception_obj = ExceptionMessage.new(people_associated_deal["message"],people_associated_deal["status"],people_associated_deal["error"])
      render :json => exception_obj.message.to_json and return
    end
  end


  def tickets(associated_people)
    unless associated_people.blank?
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      zendeskApi_obj = Zendesk.new(authentication_key.subdomain, authentication_key.access_token, authentication_key.token_type)
      render :json => zendeskApi_obj.get_all_tickets(associated_people).to_json  , :status => 200 and return
    else
      exception_obj = ExceptionMessage.new("Not Found",404,"email address of associated people not found on pipelinedeals")
      render :json => exception_obj.message.to_json and return
    end
  end


  def get_people_associated_deal(pipeline_obj,api_key,deal_id)
    pipeline_obj.deal_id = deal_id
    return pipeline_obj.get_deal_details
  end



end
