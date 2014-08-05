describe AuthorizationsController do

  context 'when no parameters defined' do
    it "should be bad request" do
      get 'new'
      expect(response.location).to match("required_parameters_missing")
    end
  end

  context 'when invalid secret key' do
    it "should be bad request" do
      @request.host = "localhost:3000"
      get 'new' , {:subdomain => 'pipelinedeals',:identifier => 'pipeline_deals_demo',:secret => 'invalid123'}
      expect(response).to redirect_to("https://pipelinedeals.zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=http://localhost:3000/authorizations/get_access_token/&client_id=pipeline_deals_demo&scope=read%2520write")
    end
  end


  context "when get_access_token method should have no code parameters" do
    it "should be bad request" do
      get 'get_access_token'
      expect(response.location).to match("auth_code_not_found")
    end
  end


  context "when request with valid parameters" do
    it "should be redirect to pipelinedeals.zendesk.com for request code" do
      @request.host = "localhost:3000"
      get 'new' , {:subdomain => 'pipelinedeals',:identifier => 'pipeline_deals_demo',:secret => '3b7a519edc83e537b7ebe8d537a0333b640732125f5a39d08a5cdc3b5d9d1761'}
      expect(response).to redirect_to("https://pipelinedeals.zendesk.com/oauth/authorizations/new?response_type=code&redirect_uri=http://localhost:3000/authorizations/get_access_token/&client_id=pipeline_deals_demo&scope=read%2520write")
    end
  end

end