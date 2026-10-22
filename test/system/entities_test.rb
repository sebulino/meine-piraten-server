require "application_system_test_case"

class EntitiesTest < ApplicationSystemTestCase
  test "index shows level and parent of each entity" do
    sign_in users(:pirat)
    visit entities_url

    assert_selector "h1", text: "Gliederungen"
    within "tr", text: entities(:kv_frankfurt).name do
      assert_text "Kreisverband"
      assert_text entities(:lv_hessen).name
    end
    assert_no_link "Neue Gliederung"
  end

  test "admin creates an entity below a parent" do
    sign_in users(:admin_pirat)
    visit entities_url
    click_on "Neue Gliederung"

    fill_in "Name", with: "KV Darmstadt"
    select "Kreisverband", from: "Gliederungsebene"
    select entities(:lv_hessen).name, from: "Übergeordnete Gliederung"
    click_on "Create Entity"

    assert_text "Entity was successfully created"
    visit entities_url
    within "tr", text: "KV Darmstadt" do
      assert_text "Kreisverband"
      assert_text entities(:lv_hessen).name
    end
  end

  test "admin edits an entity" do
    sign_in users(:admin_pirat)
    visit entity_url(entities(:bzv_oberbayern))
    click_on "Bearbeiten"

    fill_in "Name", with: "BZV Oberbayern-Nord"
    click_on "Update Entity"

    assert_text "Entity was successfully updated"
    assert_text "BZV Oberbayern-Nord"
  end

  test "admin deletes an entity without tasks" do
    sign_in users(:admin_pirat)
    visit entity_url(entities(:bzv_oberbayern))
    click_on "Löschen"

    assert_text "Entity was successfully destroyed"
    assert_no_link entities(:bzv_oberbayern).name
  end
end
