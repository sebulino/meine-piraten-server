require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  PRODUCTION_SEEDS = Rails.root.join("db/seeds/production.rb")
  DEVELOPMENT_SEEDS = Rails.root.join("db/seeds/development.rb")

  # Start from an empty catalogue, like a fresh database (fixtures are rolled back after each test)
  setup do
    Comment.delete_all
    Task.delete_all
    Entity.update_all(parent_entity_id: nil)
    Entity.delete_all
    Category.delete_all
  end

  test "production seeds create categories, Bundesverband and 16 Landesverbände" do
    assert_output(/Seeded/) { load PRODUCTION_SEEDS }

    assert_equal %w[Verwaltung Veranstaltung Wahlkampf Öffentlichkeitsarbeit].sort, Category.pluck(:name).sort

    bundesverband = Entity.find_by!(name: "Bundesverband")
    assert_equal "BV", bundesverband.entity_level
    assert_nil bundesverband.parent_entity

    landesverbaende = Entity.where(entity_level: "LV")
    assert_equal 16, landesverbaende.count
    assert landesverbaende.all? { |lv| lv.parent_entity == bundesverband }
    assert Entity.exists?(name: "LV Hessen")
  end

  test "production seeds are idempotent" do
    assert_output(/Seeded/) { load PRODUCTION_SEEDS }
    assert_no_difference [ "Category.count", "Entity.count" ] do
      assert_output(/Seeded/) { load PRODUCTION_SEEDS }
    end
  end

  test "production seeds create no users, tasks or messages" do
    assert_no_difference [ "User.count", "Task.count", "Message.count", "Comment.count" ] do
      assert_output(/Seeded/) { load PRODUCTION_SEEDS }
    end
  end

  test "development seeds run and store usernames as assignees" do
    assert_output(/Seeded/) { load DEVELOPMENT_SEEDS }

    assert_equal %w[pirat42 pirat99], Task.where.not(assignee: nil).distinct.pluck(:assignee).sort
    assert_equal "LV Hessen", Entity.find_by!(name: "KV Frankfurt").parent_entity.name
  end
end
