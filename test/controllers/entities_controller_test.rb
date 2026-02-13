require "test_helper"

class EntitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entity = entities(:lv_hessen)
  end

  test "should get index" do
    get entities_url
    assert_response :success
  end

  test "should get new" do
    get new_entity_url
    assert_response :success
  end

  test "should create entity" do
    assert_difference("Entity.count") do
      post entities_url, params: { entity: { KV: @entity.KV, LV: @entity.LV, OV: @entity.OV, entity_id: @entity.entity_id, name: @entity.name } }
    end

    assert_redirected_to entity_url(Entity.last)
  end

  test "should show entity" do
    get entity_url(@entity)
    assert_response :success
  end

  test "should get edit" do
    get edit_entity_url(@entity)
    assert_response :success
  end

  test "should update entity" do
    patch entity_url(@entity), params: { entity: { KV: @entity.KV, LV: @entity.LV, OV: @entity.OV, entity_id: @entity.entity_id, name: @entity.name } }
    assert_redirected_to entity_url(@entity)
  end

  test "should destroy entity" do
    # Use an entity with no associated tasks to avoid FK constraint
    entity_without_tasks = entities(:ov_schwabing)
    assert_difference("Entity.count", -1) do
      delete entity_url(entity_without_tasks)
    end

    assert_redirected_to entities_url
  end
end
