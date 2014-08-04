class ZendeskAuth
  attr_accessor :code
  def initialize(subdomain, identifier,secret,redirect_uri)
    @subdomain = subdomain
    @unique = identifier
    @secret = secret
    @redirect_uri = redirect_uri
  end

#zendesk API URL for requesting authorizations code
  def get_request_auth_code_url
    URI.encode("https://#{@subdomain}.zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=#{@redirect_uri}/&client_id=#{@unique}&scope=read%20write")
  end

  #parse json for access token
  def get_access_token
    token_hash = Hash.new
    token_obj = get_access_token_json
    if token_obj.response.code.to_i == 200
      response_json = JSON.parse token_obj.response.body
      token_hash["access_token"]= response_json["access_token"]
      token_hash["token_type"]= response_json["token_type"]
    end
    return token_hash
  end


  private
  #zendesk API URL for requesting tokens by using code
  def get_request_access_token_url
    URI.encode('https://'"#{@subdomain}"'.zendesk.com/oauth/tokens?grant_type=authorization_code&code='+ @code + '&client_id='+ @unique +'&client_secret='+ @secret +'&redirect_uri='"#{@redirect_uri}"'/&scope=read%20write')
  end

  #Sending a post query sent via HTTParty
  def get_access_token_json
    HTTParty.post(get_request_access_token_url)
  end
end