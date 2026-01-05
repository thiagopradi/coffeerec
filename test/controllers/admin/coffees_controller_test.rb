require "test_helper"

class Admin::CoffeesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffee = Coffee.create!(
      name: "Test Coffee",
      description: "A test coffee",
      roast_level: "medium",
      acidity: 5,
      body: 6,
      sweetness: 7,
      bitterness: 4
    )
    @coffee.generate_embedding!
    @auth_headers = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "coffee123") }
  end

  test "requires authentication" do
    get admin_coffees_path
    assert_response :unauthorized
  end

  test "index shows all coffees" do
    get admin_coffees_path, headers: @auth_headers
    assert_response :success
    assert_match @coffee.name, response.body
  end

  test "show displays coffee details" do
    get admin_coffee_path(@coffee), headers: @auth_headers
    assert_response :success
    assert_match @coffee.name, response.body
  end

  test "new renders form" do
    get new_admin_coffee_path, headers: @auth_headers
    assert_response :success
  end

  test "create adds new coffee with embedding" do
    assert_difference "Coffee.count", 1 do
      post admin_coffees_path, params: {
        coffee: {
          name: "New Coffee",
          description: "Fresh roasted",
          roast_level: "light",
          acidity: 8,
          body: 4,
          sweetness: 6,
          bitterness: 3
        }
      }, headers: @auth_headers
    end
    new_coffee = Coffee.last
    assert_redirected_to admin_coffee_path(new_coffee)
    assert_not_nil new_coffee.flavor_embedding
  end

  test "create with invalid data renders form" do
    assert_no_difference "Coffee.count" do
      post admin_coffees_path, params: { coffee: { name: "" } }, headers: @auth_headers
    end
    assert_response :unprocessable_entity
  end

  test "update modifies coffee and regenerates embedding" do
    old_embedding = @coffee.flavor_embedding.to_a

    patch admin_coffee_path(@coffee), params: { coffee: { acidity: 9 } }, headers: @auth_headers
    assert_redirected_to admin_coffee_path(@coffee)

    @coffee.reload
    assert_equal 9, @coffee.acidity
    assert_not_equal old_embedding, @coffee.flavor_embedding.to_a
  end

  test "destroy removes coffee" do
    assert_difference "Coffee.count", -1 do
      delete admin_coffee_path(@coffee), headers: @auth_headers
    end
    assert_redirected_to admin_coffees_path
  end
end
