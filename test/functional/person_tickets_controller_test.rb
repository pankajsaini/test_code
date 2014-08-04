require 'test_helper'

class PersonTicketsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end
