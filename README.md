# Meine Piraten Server

Task management and team coordination platform for the Piratenpartei (Pirate Party Germany). Provides both a web interface and a JSON API consumed by an iOS app.

## Features

### Task Management
- Create, edit, and delete tasks with title, description, due date, urgency flag, time estimate, and activity points
- Tasks are assigned to an **entity** (organizational unit) and a **category**
- Status workflow with strict state machine transitions: `open` → `claimed` → `completed` → `done`
- Regular users can claim, release, and complete tasks; admins confirm completion and manage all transitions

### Comments
- Threaded comments on tasks
- Any authenticated user can comment; admins can delete comments

### Categories & Entities
- **Categories** organize tasks by topic (e.g. Wahlkampf, IT, Kommunikation)
- **Entities** represent the party's organizational hierarchy (Landesverband, Kreisverband, Ortsverband) with parent/child relationships
- Admin-only CRUD for both

### Authentication
- **Web UI:** Single sign-on via PiratenSSO (Keycloak OpenID Connect)
- **API:** Bearer token (JWT) authentication with RS256 signature verification against the Keycloak JWKS endpoint
- Development mode auto-creates a local admin/superadmin user

### Authorization & Roles
- **Regular users** — view tasks/entities/categories, claim tasks, add comments, request admin access
- **Admins** — create/edit/delete tasks, entities, categories; manage comments; confirm task completion
- **Superadmins** — review, approve, or reject admin access requests (approving grants admin privileges)

### Admin Request Workflow
- Users submit admin access requests with a reason via the JSON API (`POST /admin_requests.json`)
- Superadmins review requests in a dedicated web view and approve or reject them
- Approval automatically grants admin rights to the requesting user

### JSON API
- Full REST API for tasks and comments (used by the iOS app)
- API documentation available at `/api` in the web UI
- Endpoints: tasks (CRUD), comments (list/create/delete), admin requests (create)

## Tech Stack

- **Framework:** Ruby on Rails 8.1
- **Database:** SQLite 3
- **Authentication:** Devise + omniauth_openid_connect + JWT
- **Frontend:** Hotwire (Turbo + Stimulus), importmap-rails, Propshaft
- **Deployment:** Kamal (Docker-based)
- **Background jobs:** Solid Queue
- **Caching:** Solid Cache
- **WebSockets:** Solid Cable

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version`)
- SQLite 3

### Setup

```sh
bundle install
bin/rails db:setup
bin/rails server
```

In development, you are automatically signed in as a superadmin user.

### Running Tests

```sh
bin/rails test
```

### API Authentication

Obtain a JWT from PiratenSSO and include it in requests:

```sh
curl -H "Authorization: Bearer <token>" \
     https://meine-piraten.de/tasks.json
```

See `/api` for full API documentation.
