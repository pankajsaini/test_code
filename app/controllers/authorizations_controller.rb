require "zendesk_auth"
class AuthorizationsController < ApplicationController
  before_filter :only => [:new] do |c| c.required_auth_parameter params[:subdomain],params[:identifier],params[:secret] end

  #redirect to zendesk for app authorizations
  def new
      auth_obj = ZendeskAuth.new(session[:subdomain],session[:identifier],session[:secret],authorizations_get_access_token_url)
      redirect_to auth_obj.get_request_auth_code_url
  end

  #get code params from zendesk and make request for get access_token and token_type.
  def get_access_token
    unless params[:code].blank?
      auth_obj = ZendeskAuth.new(session[:subdomain],session[:identifier],session[:secret],authorizations_get_access_token_url)
      auth_obj.code = params[:code]
      response = auth_obj.get_access_token
      save_access_token(response)
    else
      redirect_to return_message("error","auth_code_not_found") and return
    end

  end

  #method for updating or creating access token
  def save_access_token(response)
    unless response.empty?
      authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
      store_access_token(authentication_key,response)
      redirect_to return_message("success","authenticated_successfully") and return
    else
      redirect_to return_message("error","access_token_not_found") and return
    end
  end


  def store_access_token(authentication_key,response)
    unless authentication_key.nil?
      authentication_key.update_attributes(:unique_identifier => session[:identifier],:secret => session[:secret],:access_token =>response['access_token'],:token_type => response['token_type'])
    else
      AuthenticationKey.create(:subdomain => session[:subdomain],:unique_identifier => session[:identifier],:secret => session[:secret],:access_token =>response['access_token'],:token_type => response['token_type'])
    end
  end


  def return_message(messages_type,message)
    "https://www.pipelinedeals.com/admin/partner_integrations?#{messages_type}=#{message}"
  end

  #method for creating session
  def required_auth_parameter(subdomain,identifier,secret)
    if subdomain.blank? or identifier.blank? or secret.blank?
      redirect_to return_message("error","required_parameters_missing")
    else
    session[:subdomain] = subdomain
    session[:identifier] = identifier
    session[:secret] = secret
    end
  end

end
