# Seed data for development — matches iOS FakeTodoRepository sample data.
# Idempotent: safe to run multiple times via `bin/rails db:seed`.

# --- Categories ---
categories = {}
%w[Wahlkampf Verwaltung Oeffentlichkeitsarbeit Veranstaltung].each do |name|
  categories[name] = Category.find_or_create_by!(name: name)
end

# --- Entities (hierarchical) ---
lv_hessen = Entity.find_or_create_by!(name: "LV Hessen") do |e|
  e.LV = true; e.OV = false; e.KV = false; e.entity_id = nil
end

kv_frankfurt = Entity.find_or_create_by!(name: "KV Frankfurt") do |e|
  e.LV = false; e.OV = false; e.KV = true; e.entity_id = lv_hessen.id
end

lv_bayern = Entity.find_or_create_by!(name: "LV Bayern") do |e|
  e.LV = true; e.OV = false; e.KV = false; e.entity_id = nil
end

kv_muenchen = Entity.find_or_create_by!(name: "KV Muenchen") do |e|
  e.LV = false; e.OV = false; e.KV = true; e.entity_id = lv_bayern.id
end

ov_schwabing = Entity.find_or_create_by!(name: "OV Schwabing") do |e|
  e.LV = false; e.OV = true; e.KV = false; e.entity_id = kv_muenchen.id
end

# --- Tasks ---
t1 = Task.find_or_create_by!(title: "Wahlkampfmaterial bestellen") do |t|
  t.description = "Flyer und Plakate fuer den Infostand am Samstag vorbereiten."
  t.entity = kv_frankfurt; t.category = categories["Wahlkampf"]
  t.status = "open"; t.urgent = true; t.activity_points = 10
  t.time_needed_in_hours = 2; t.creator_name = "pirat42"
  t.due_date = 4.days.from_now.to_date
end

t2 = Task.find_or_create_by!(title: "Protokoll der letzten Sitzung") do |t|
  t.description = "Protokoll der Kreisvorstandssitzung vom 25.01. ins Wiki eintragen."
  t.entity = kv_muenchen; t.category = categories["Verwaltung"]
  t.status = "claimed"; t.assignee = "pirat42"; t.activity_points = 5
  t.time_needed_in_hours = 1; t.creator_name = "pirat99"
  t.due_date = 1.day.ago.to_date
end

Task.find_or_create_by!(title: "Pressemitteilung Digitalisierung") do |t|
  t.entity = lv_hessen; t.category = categories["Oeffentlichkeitsarbeit"]
  t.status = "open"; t.activity_points = 15
  t.time_needed_in_hours = 3; t.creator_name = "pirat42"
  t.due_date = 7.days.from_now.to_date
end

Task.find_or_create_by!(title: "Social Media Posts vorbereiten") do |t|
  t.description = "3-5 Posts fuer die kommende Woche zum Thema Netzpolitik."
  t.entity = kv_frankfurt; t.category = categories["Oeffentlichkeitsarbeit"]
  t.status = "claimed"; t.assignee = "pirat99"; t.creator_name = "pirat42"
end

Task.find_or_create_by!(title: "Newsletter-Entwurf pruefen") do |t|
  t.description = "Korrekturlesen des monatlichen Newsletters."
  t.entity = lv_bayern; t.category = categories["Oeffentlichkeitsarbeit"]
  t.status = "done"; t.assignee = "pirat42"; t.urgent = true; t.activity_points = 5
  t.time_needed_in_hours = 1; t.creator_name = "pirat99"; t.completed = true
  t.due_date = 2.days.ago.to_date
end

Task.find_or_create_by!(title: "Raumreservierung Stammtisch") do |t|
  t.description = "Raum fuer den monatlichen Stammtisch im Februar reservieren."
  t.entity = kv_muenchen; t.category = categories["Veranstaltung"]
  t.status = "done"; t.assignee = "pirat99"; t.activity_points = 3
  t.creator_name = "pirat42"; t.completed = true
  t.due_date = 5.days.ago.to_date
end

# --- Comments ---
Comment.find_or_create_by!(task: t1, author_name: "pirat42", text: "Kann ich Samstag mitbringen.")
Comment.find_or_create_by!(task: t1, author_name: "pirat99", text: "Bitte auch Aufkleber bestellen.")
Comment.find_or_create_by!(task: t2, author_name: "pirat42", text: "Hier ist der Link zum Wiki-Eintrag.")

puts "Seeded: #{Category.count} categories, #{Entity.count} entities, #{Task.count} tasks, #{Comment.count} comments"
