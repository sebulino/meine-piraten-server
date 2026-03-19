require "application_system_test_case"

class EntitiesTest < ApplicationSystemTestCase
  setup do
    @entity = entities(:lv_hessen)
  end

  test "visiting the index" do
    visit entities_url
    assert_selector "h1", text: "Gliederungen"
  end

  test "should create entity" do
    visit entities_url
    click_on "Neue Gliederung"

    fill_in "Name", with: "LV Test"
    select "Landesverband", from: "Gliederungsebene"
    click_on "Create Entity"

    assert_text "Entity was successfully created"
  end

  test "should update Entity" do
    visit entity_url(@entity)
    click_on "Edit this entity", match: :first

    fill_in "Name", with: @entity.name
    select "Landesverband", from: "Gliederungsebene"
    click_on "Update Entity"

    assert_text "Entity was successfully updated"
  end

  test "should destroy Entity" do
    visit entity_url(@entity)
    click_on "Destroy this entity", match: :first

    assert_text "Entity was successfully destroyed"
  end
end
