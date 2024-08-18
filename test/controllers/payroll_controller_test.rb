require "test_helper"

class NetPayControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get net_pay_show_url
    assert_response :success
  end
end
