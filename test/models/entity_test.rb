require "test_helper"

class EntityTest < ActiveSupport::TestCase
  test "parent_entity association returns the parent" do
    kv = entities(:kv_frankfurt)
    assert_equal entities(:lv_hessen), kv.parent_entity
  end

  test "sub_entities association returns children" do
    lv = entities(:lv_bayern)
    assert_includes lv.sub_entities, entities(:kv_muenchen)
    assert_includes lv.sub_entities, entities(:bzv_oberbayern)
  end

  test "root entity has nil parent" do
    lv = entities(:lv_hessen)
    assert_nil lv.parent_entity
  end

  test "cannot reference self as parent" do
    entity = entities(:lv_hessen)
    entity.entity_id = entity.id
    assert_not entity.valid?
    assert_includes entity.errors[:entity_id], "kann nicht auf sich selbst verweisen"
  end

  test "cannot create circular reference" do
    lv = entities(:lv_bayern)
    kv = entities(:kv_muenchen)
    # Make LV Bayern point to KV Muenchen (which already points to LV Bayern)
    lv.entity_id = kv.id
    assert_not lv.valid?
    assert_includes lv.errors[:entity_id], "würde einen Zirkelbezug erzeugen"
  end

  test "valid parent reference is accepted" do
    entity = Entity.new(name: "KV Test", entity_level: "KV", entity_id: entities(:lv_hessen).id)
    assert entity.valid?
  end

  test "deleting parent nullifies children" do
    parent = Entity.create!(name: "Parent Test", entity_level: "LV")
    child = Entity.create!(name: "Child Test", entity_level: "KV", entity_id: parent.id)
    parent.destroy!
    child.reload
    assert_nil child.entity_id
  end
end
