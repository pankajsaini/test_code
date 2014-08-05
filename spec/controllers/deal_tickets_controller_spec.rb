describe DealTicketsController do
  context 'when no parameters defined' do
    it "has Bad Request 400 code required parameters missing if no subdomain , secret key and deal id" do
      get 'show'
      expect(response.status).to eq(400)
    end
  end

  context 'when no secret key and deal id' do
    it "has Bad Request 400 code required parameters missing if no secret key and deal id" do
      get 'show', {:subdomain => 'pipelinedeals'}
      expect(response.status).to eq(400)
    end
  end

  context 'when no deal id' do
    it "has Bad Request 400 code required parameters missing if no deal id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW'}
      expect(response.status).to eq(400)
    end
  end

  context 'when invalid secret key' do
    it "has Unauthorized 401 code if valid subdomain and deal id but invalid secret" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'invalid',:deal_id => '21295979'}
      expect(response.status).to eq(401)
    end
  end


  context 'when invalid deal id' do
    it "has Not Found with 404 status code if subdomain, secret and invalid deal id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:deal_id => '0003234'}
      expect(response.status).to eq(404)
    end
  end

  context 'when valid parameters for GET Request' do
    it "has 200 status code if GET request with valid subdomain,secret and deal id" do
      get 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:deal_id => '6259998'}
      expect(response.status).to eq(200)
    end
  end

  context 'when valid parameters for POST Request' do
    it "has 200 status code if POST request with valid subdomain,secret and deal id" do
      post 'show', {:subdomain => 'pipelinedeals',:api_key => 'CuQxWURE6tHVrURlucW',:deal_id => '6259998'}
      expect(response.status).to eq(200)
    end
  end

end