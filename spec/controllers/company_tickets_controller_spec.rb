describe CompanyTicketsController do
  context 'when no parameters defined' do
    it "has 400 code required parameters missing if no subdomain , secret key and company id" do
      get 'show'
      expect(response.status).to eq(400)
    end
  end

  context 'when no secret key and company id' do
    it "has 400 code required parameters missing if no secret key and company id" do
      get 'show', {:subdomain => 'pipelinedeals'}
      expect(response.status).to eq(400)
    end
  end

  context 'when no company id' do
    it "has 400 code required parameters missing if no company id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW'}
      expect(response.status).to eq(400)
    end
  end

  context 'when invalid secret key' do
    it "has 401 Unauthorized code if valid subdomain and company id but invalid secret" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'invalid',:company_id => '21295979'}
      expect(response.status).to eq(401)
    end
  end


  context 'when invalid company id' do
    it "has 404 Not Found status code if subdomain, secret and invalid company id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:company_id => '0003234'}
      expect(response.status).to eq(404)
    end
  end

  context 'when valid parameters for GET Request' do
    it "has 200 status code if GET request with valid subdomain,secret and company id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:company_id => '21295979'}
      expect(response.status).to eq(200)
    end
  end

  context 'when valid parameters for POST Request' do
    it "has 200 status code if POST request with valid subdomain,secret and company id" do
      post 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:company_id => '21295979'}
      expect(response.status).to eq(200)
    end
  end

end