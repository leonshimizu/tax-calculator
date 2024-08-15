require "test_helper"

class TaxCalculatorControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    get tax_calculator_calculate_url
    assert_response :success
  end
end
