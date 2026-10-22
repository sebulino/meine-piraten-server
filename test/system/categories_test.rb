require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  test "regular user sees categories but cannot manage them" do
    sign_in users(:pirat)
    visit categories_url

    assert_selector "h1", text: "Kategorien"
    assert_link categories(:wahlkampf).name
    assert_no_link "Neue Kategorie"

    click_on categories(:wahlkampf).name
    assert_no_link "Bearbeiten"
    assert_no_button "Löschen"
  end

  test "admin creates a category" do
    sign_in users(:admin_pirat)
    visit categories_url
    click_on "Neue Kategorie"

    fill_in "Name", with: "Bildung"
    click_on "Create Category"

    assert_text "Category was successfully created"
  end

  test "admin edits a category" do
    sign_in users(:admin_pirat)
    visit category_url(categories(:verwaltung))
    click_on "Bearbeiten"

    fill_in "Name", with: "Verwaltung & Finanzen"
    click_on "Update Category"

    assert_text "Category was successfully updated"
    assert_text "Verwaltung & Finanzen"
  end

  test "admin deletes an unused category" do
    sign_in users(:admin_pirat)
    visit category_url(categories(:unused_category))
    click_on "Löschen"

    assert_text "Category was successfully destroyed"
    assert_no_link categories(:unused_category).name
  end
end
