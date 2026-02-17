require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:wahlkampf)
  end

  # -- Read access (all authenticated users) --

  test "should get index" do
    sign_in users(:pirat)
    get categories_url
    assert_response :success
  end

  test "should show category" do
    sign_in users(:pirat)
    get category_url(@category)
    assert_response :success
  end

  # -- Admin-only write actions --

  test "admin should get new" do
    sign_in users(:admin_pirat)
    get new_category_url
    assert_response :success
  end

  test "regular user should not get new" do
    sign_in users(:pirat)
    get new_category_url
    assert_redirected_to root_path
  end

  test "admin should create category" do
    sign_in users(:admin_pirat)
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "Neue Kategorie" } }
    end

    assert_redirected_to category_url(Category.last)
  end

  test "regular user should not create category" do
    sign_in users(:pirat)
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: "Neue Kategorie" } }
    end

    assert_redirected_to root_path
  end

  test "admin should get edit" do
    sign_in users(:admin_pirat)
    get edit_category_url(@category)
    assert_response :success
  end

  test "regular user should not get edit" do
    sign_in users(:pirat)
    get edit_category_url(@category)
    assert_redirected_to root_path
  end

  test "admin should update category" do
    sign_in users(:admin_pirat)
    patch category_url(@category), params: { category: { name: @category.name } }
    assert_redirected_to category_url(@category)
  end

  test "regular user should not update category" do
    sign_in users(:pirat)
    patch category_url(@category), params: { category: { name: "Hacked" } }
    assert_redirected_to root_path
  end

  test "admin should destroy category" do
    sign_in users(:admin_pirat)
    category_without_tasks = categories(:unused_category)
    assert_difference("Category.count", -1) do
      delete category_url(category_without_tasks)
    end

    assert_redirected_to categories_url
  end

  test "regular user should not destroy category" do
    sign_in users(:pirat)
    category_without_tasks = categories(:unused_category)
    assert_no_difference("Category.count") do
      delete category_url(category_without_tasks)
    end

    assert_redirected_to root_path
  end
end
