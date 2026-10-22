# Base data for a fresh production database. No users, tasks or messages.
# Idempotent: safe to run multiple times via `bin/rails db:seed`.
# Superadmin: log in via Keycloak once, then run `bin/rails "users:make_superadmin[<username>]"`.

# --- Categories ---
%w[Wahlkampf Verwaltung Öffentlichkeitsarbeit Veranstaltung].each do |name|
  Category.find_or_create_by!(name: name)
end

# --- Entities (Bundesverband → Landesverbände) ---
bundesverband = Entity.find_or_create_by!(name: "Bundesverband") do |e|
  e.entity_level = "BV"
end

[
  "Baden-Württemberg", "Bayern", "Berlin", "Brandenburg", "Bremen", "Hamburg",
  "Hessen", "Mecklenburg-Vorpommern", "Niedersachsen", "Nordrhein-Westfalen",
  "Rheinland-Pfalz", "Saarland", "Sachsen", "Sachsen-Anhalt", "Schleswig-Holstein", "Thüringen"
].each do |land|
  Entity.find_or_create_by!(name: "LV #{land}") do |e|
    e.entity_level = "LV"; e.parent_entity = bundesverband
  end
end

puts "Seeded: #{Category.count} categories, #{Entity.count} entities"
