require "zendesk_auth"
class AuthorizationsController < ApplicationController

  def new
    if params[:subdomain].blank? && params[:identifier].blank? && params[:secret].blank?
      redirect_to return_message("error","required_parameters_missing") and return
    else
      session[:subdomain] = params[:subdomain]
      session[:identifier] = params[:identifier]
      session[:secret] = params[:secret]
      auth_obj = ZendeskAuth.new(session[:subdomain],session[:identifier],session[:secret],authorizations_get_access_token_url)
      redirect_to auth_obj.get_request_auth_code_url
    end
  end


  def get_access_token
    # zendesk outh URL return response in this method.
    unless params[:code].blank?
      auth_obj = ZendeskAuth.new(session[:subdomain],session[:identifier],session[:secret],authorizations_get_access_token_url)
      auth_obj.code = params[:code]
      response = auth_obj.get_access_token
      unless response.empty?
        authentication_key= AuthenticationKey.authenticate_subdomain(session[:subdomain])
        store_access_token(authentication_key,response)
        redirect_to return_message("success","authenticated_successfully") and return
      else
        redirect_to return_message("error","access_token_not_found") and return
      end
    else
      redirect_to return_message("error","auth_code_not_found") and return
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
    URI.encode("https://www.pipelinedeals.com/admin/partner_integrations?#{messages_type}=#{message}")
  end

end
