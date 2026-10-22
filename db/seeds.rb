# Loads db/seeds/<environment>.rb if present.
# Runs via `bin/rails db:seed` and on fresh databases via `db:prepare` (Docker entrypoint).
seed_file = Rails.root.join("db/seeds/#{Rails.env}.rb")
load seed_file if seed_file.exist?
