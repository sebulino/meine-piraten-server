namespace :users do
  desc "Grant admin + superadmin to a user by Keycloak username (user must have logged in once)"
  task :make_superadmin, [ :username ] => :environment do |_task, args|
    username = args[:username].presence or abort "Usage: bin/rails \"users:make_superadmin[<username>]\""

    users = User.where(preferred_username: username)
    abort "No user '#{username}' found. Log in via Keycloak once first, then rerun." if users.none?
    abort "Multiple users named '#{username}' (uids: #{users.pluck(:uid).join(", ")}). Fix manually." if users.many?

    user = users.first
    if user.superadmin?
      puts "#{username} is already superadmin."
    else
      user.update!(admin: true, superadmin: true)
      puts "#{username} (uid #{user.uid}) is now admin + superadmin."
    end
  end
end
