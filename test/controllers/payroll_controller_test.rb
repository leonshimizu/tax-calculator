require "test_helper"

class PayrollControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get payroll_show_url
    assert_response :success
  end
end
