require "test_helper"

class EntitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entity = entities(:lv_hessen)
  end

  # -- Read access (all authenticated users) --

  test "should get index" do
    sign_in users(:pirat)
    get entities_url
    assert_response :success
  end

  test "should show entity" do
    sign_in users(:pirat)
    get entity_url(@entity)
    assert_response :success
  end

  # -- Admin-only write actions --

  test "admin should get new" do
    sign_in users(:admin_pirat)
    get new_entity_url
    assert_response :success
  end

  test "regular user should not get new" do
    sign_in users(:pirat)
    get new_entity_url
    assert_redirected_to root_path
  end

  test "admin should create entity" do
    sign_in users(:admin_pirat)
    assert_difference("Entity.count") do
      post entities_url, params: { entity: { KV: @entity.KV, LV: @entity.LV, OV: @entity.OV, entity_id: @entity.entity_id, name: @entity.name } }
    end

    assert_redirected_to entity_url(Entity.last)
  end

  test "regular user should not create entity" do
    sign_in users(:pirat)
    assert_no_difference("Entity.count") do
      post entities_url, params: { entity: { KV: @entity.KV, LV: @entity.LV, OV: @entity.OV, entity_id: @entity.entity_id, name: @entity.name } }
    end

    assert_redirected_to root_path
  end

  test "admin should get edit" do
    sign_in users(:admin_pirat)
    get edit_entity_url(@entity)
    assert_response :success
  end

  test "regular user should not get edit" do
    sign_in users(:pirat)
    get edit_entity_url(@entity)
    assert_redirected_to root_path
  end

  test "admin should update entity" do
    sign_in users(:admin_pirat)
    patch entity_url(@entity), params: { entity: { KV: @entity.KV, LV: @entity.LV, OV: @entity.OV, entity_id: @entity.entity_id, name: @entity.name } }
    assert_redirected_to entity_url(@entity)
  end

  test "regular user should not update entity" do
    sign_in users(:pirat)
    patch entity_url(@entity), params: { entity: { name: "Hacked" } }
    assert_redirected_to root_path
  end

  test "admin should destroy entity" do
    sign_in users(:admin_pirat)
    entity_without_tasks = entities(:ov_schwabing)
    assert_difference("Entity.count", -1) do
      delete entity_url(entity_without_tasks)
    end

    assert_redirected_to entities_url
  end

  test "regular user should not destroy entity" do
    sign_in users(:pirat)
    entity_without_tasks = entities(:ov_schwabing)
    assert_no_difference("Entity.count") do
      delete entity_url(entity_without_tasks)
    end

    assert_redirected_to root_path
  end
end
