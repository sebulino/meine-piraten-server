require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "signed-out visitor is sent to the SSO login" do
    visit tasks_url
    assert_button "Mit PiratenSSO anmelden"
  end

  test "regular user sees tasks but no admin controls" do
    sign_in users(:pirat)
    visit tasks_url

    assert_selector "h1", text: "Was gibt es alles zu tun?"
    assert_link tasks(:wahlkampfmaterial).title
    assert_no_link "Neues ToDo"

    click_on tasks(:wahlkampfmaterial).title
    assert_no_link "Bearbeiten"
    assert_no_button "Löschen"
  end

  test "regular user claims, releases and completes a task" do
    sign_in users(:pirat)
    visit task_url(tasks(:wahlkampfmaterial))

    click_on "Übernehmen"
    assert_text "Task was successfully updated"
    assert_selector ".badge-claimed", text: "Übernommen"

    click_on "Freigeben"
    assert_selector ".badge-open", text: "Offen"

    click_on "Übernehmen"
    click_on "Abschließen"
    assert_selector ".badge-completed", text: "Bearbeitet"
    assert_no_button "Bestätigen"
  end

  test "admin creates a task" do
    sign_in users(:admin_pirat)
    visit tasks_url
    click_on "Neues ToDo"

    fill_in "Titel", with: "Infostand aufbauen"
    fill_in "Beschreibung", with: "Samstag 10 Uhr am Marktplatz"
    fill_in "Erstellt von", with: "adminpirat"
    fill_in "Zeitaufwand (Stunden)", with: 3
    check "Dringend"
    select categories(:wahlkampf).name, from: "Kategorie"
    select entities(:kv_frankfurt).name, from: "Gliederung"
    click_on "Create Task"

    assert_text "Task was successfully created"
    assert_selector "h2", text: "Infostand aufbauen"
    assert_selector ".badge-urgent"
  end

  test "admin sees validation errors for an incomplete task" do
    sign_in users(:admin_pirat)
    visit new_task_url
    click_on "Create Task"

    assert_selector ".form-errors"
  end

  test "admin edits a task" do
    task = tasks(:pressemitteilung)
    sign_in users(:admin_pirat)
    visit task_url(task)
    click_on "Bearbeiten"

    fill_in "Titel", with: "Pressemitteilung Netzpolitik"
    click_on "Update Task"

    assert_text "Task was successfully updated"
    assert_selector "h2", text: "Pressemitteilung Netzpolitik"
  end

  test "admin confirms a completed task" do
    sign_in users(:admin_pirat)
    visit task_url(tasks(:website_update))

    click_on "Bestätigen"
    assert_selector ".badge-done", text: "Erledigt"
  end

  test "admin deletes a task" do
    task = tasks(:pressemitteilung)
    sign_in users(:admin_pirat)
    visit task_url(task)
    click_on "Löschen"

    assert_text "Task was successfully destroyed"
    assert_no_link task.title
  end
end
