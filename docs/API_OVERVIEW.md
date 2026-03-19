# meine-piraten.de API Overview

## General

- **Base URL:** `https://meine-piraten.de` (production) / `http://localhost:3000` (development)
- **Format:** JSON (append `.json` to endpoints or use `Accept: application/json`)
- **Authentication:** Dual-mode — Keycloak OpenID Connect SSO for web UI (via Devise), Bearer JWT (RS256) for API
- **Framework:** Rails 8.1.2 with jbuilder for JSON serialization
- **Database:** SQLite3

### Authentication

All API endpoints require a valid JWT in the `Authorization` header unless noted otherwise:

```
Authorization: Bearer <access_token>
```

Tokens are issued by Keycloak and verified via the JWKS endpoint (RS256). Unauthenticated requests return `401 Unauthorized`.

**Public endpoints** (no auth required): `GET /api/news.json`

---

## Resources

### Tasks

A task represents an actionable item assigned to an organizational entity and category.

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/tasks.json` | List all tasks |
| GET | `/tasks/:id.json` | Get a single task |
| POST | `/tasks.json` | Create a task (admin only) |
| PATCH/PUT | `/tasks/:id.json` | Update a task |
| DELETE | `/tasks/:id.json` | Delete a task (admin only) |

#### Request Parameters (create/update)

Wrap parameters in a `task` key:

```json
{
  "task": {
    "title": "string (required, max 200 characters)",
    "description": "text (optional, max 2000 characters)",
    "completed": "boolean",
    "creator_name": "string",
    "time_needed_in_hours": "integer (optional)",
    "activity_points": "integer (optional)",
    "due_date": "date (YYYY-MM-DD, optional)",
    "urgent": "boolean (optional)",
    "category_id": "integer (required, foreign key)",
    "entity_id": "integer (required, foreign key)",
    "status": "string (optional, one of: open, claimed, completed, done; default: open; see status transitions below)",
    "assignee_id": "integer (optional, foreign key → users)"
  }
}
```

#### Response Shape (single task)

```json
{
  "id": 1,
  "title": "Wahlkampfmaterial bestellen",
  "description": "Flyer und Plakate für den Wahlkampf bestellen",
  "completed": false,
  "creator_name": "pirat42",
  "time_needed_in_hours": 2,
  "due_date": "2025-06-01",
  "urgent": true,
  "activity_points": 10,
  "category_id": 1,
  "entity_id": 1,
  "status": "open",
  "assignee_id": null,
  "assignee_name": null,
  "created_at": "2025-05-04T12:00:00.000Z",
  "updated_at": "2025-05-04T12:00:00.000Z",
  "url": "https://meine-piraten.de/tasks/1.json"
}
```

#### Status Transitions

Task status follows a strict state machine. Invalid transitions return **422 Unprocessable Entity**.

| From | Allowed transitions |
|------|-------------------|
| `open` | `claimed` |
| `claimed` | `completed`, `open` |
| `completed` | `done` (admin only), `claimed` |
| `done` | *(none — terminal state)* |

Regular users can only perform `open → claimed`, `claimed → open`, and `claimed → completed`. Admins can perform all valid transitions.

---

### Messages

Private messages between users. All endpoints require JWT authentication.

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/messages` | List received messages (inbox) |
| POST | `/api/messages` | Send a message |
| PATCH | `/api/messages/:id` | Mark a message as read |

#### GET /api/messages

Returns the 50 most recent messages received by the authenticated user, ordered by newest first.

**Response:**
```json
[
  {
    "id": 1,
    "sender_id": 42,
    "body": "Kannst du die Flyer bis Freitag fertig haben?",
    "read": false,
    "created_at": "2026-03-19T10:30:00Z"
  }
]
```

#### POST /api/messages

Send a message to another user.

**Request body:**
```json
{
  "recipient_id": 42,
  "body": "Ja, kein Problem!"
}
```

**Response:** `201 Created`
```json
{
  "id": 2
}
```

**Errors:** `422 Unprocessable Entity` if body is blank or recipient is invalid.

#### PATCH /api/messages/:id

Marks a received message as read. Only the recipient can mark their own messages.

**Response:** `200 OK` with `{}`

**Errors:** `404 Not Found` if the message doesn't belong to the authenticated user.

---

### Push Subscriptions

Register/deregister APNs device tokens for push notifications. All endpoints require JWT authentication.

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/push_subscriptions` | Register or update a device token |
| DELETE | `/api/push_subscriptions/:token` | Deregister a device token |

#### POST /api/push_subscriptions

Register a device token or update notification preferences for an existing token (upsert).

**Request body:**
```json
{
  "token": "a1b2c3d4e5f6...",
  "platform": "ios",
  "messages": true,
  "todos": false,
  "forum": true,
  "news": false
}
```

**Response:** `200 OK` with `{}`

**Errors:** `422 Unprocessable Entity` if validation fails.

#### DELETE /api/push_subscriptions/:token

Remove a device token registration. Idempotent — returns `200 OK` even if the token is unknown.

**Response:** `200 OK` with `{}`

---

### News

Telegram channel posts. **Public endpoint — no authentication required.**

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/news.json` | List recent news posts |

#### GET /api/news.json

Returns up to 50 recent channel posts (configurable via `?limit=N`, max 200), ordered by newest first. Posts older than 30 days are excluded.

**Response:**
```json
[
  {
    "chat_id": -1001234567890,
    "message_id": 42,
    "posted_at": "2026-03-19T10:00:00Z",
    "text": "Neue Pressemitteilung..."
  }
]
```

---

### Entities

An entity represents an organizational unit (e.g. Kreisverband, Landesverband, Ortsverband).

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/entities.json` | List all entities |
| GET | `/entities/:id.json` | Get a single entity |
| POST | `/entities.json` | Create an entity |
| PATCH/PUT | `/entities/:id.json` | Update an entity |
| DELETE | `/entities/:id.json` | Delete an entity |

#### Request Parameters (create/update)

```json
{
  "entity": {
    "name": "string",
    "LV": "boolean",
    "OV": "boolean",
    "KV": "boolean",
    "entity_id": "integer (optional, self-referencing parent entity)"
  }
}
```

#### Response Shape (single entity)

```json
{
  "id": 1,
  "name": "KV Frankfurt",
  "LV": false,
  "OV": false,
  "KV": true,
  "entity_id": 2,
  "created_at": "2025-04-04T14:07:33.000Z",
  "updated_at": "2025-04-04T14:07:33.000Z",
  "url": "https://meine-piraten.de/entities/1.json"
}
```

---

### Categories

A category classifies tasks (e.g. "Wahlkampf", "Verwaltung", "Veranstaltung").

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/categories.json` | List all categories |
| GET | `/categories/:id.json` | Get a single category |
| POST | `/categories.json` | Create a category |
| PATCH/PUT | `/categories/:id.json` | Update a category |
| DELETE | `/categories/:id.json` | Delete a category |

#### Request Parameters (create/update)

```json
{
  "category": {
    "name": "string"
  }
}
```

#### Response Shape (single category)

```json
{
  "id": 1,
  "name": "Wahlkampf",
  "created_at": "2025-04-04T14:27:33.000Z",
  "updated_at": "2025-04-04T14:27:33.000Z",
  "url": "https://meine-piraten.de/categories/1.json"
}
```

---

### Comments

Comments are nested under tasks. Each comment belongs to a task.

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/tasks/:task_id/comments.json` | List comments for a task |
| POST | `/tasks/:task_id/comments.json` | Create a comment on a task |
| DELETE | `/tasks/:task_id/comments/:id.json` | Delete a comment |

#### Request Parameters (create)

```json
{
  "comment": {
    "author_name": "string",
    "text": "string (required)"
  }
}
```

#### Response Shape (single comment)

```json
{
  "id": 1,
  "task_id": 1,
  "author_name": "pirat42",
  "text": "Flyer sind bestellt.",
  "created_at": "2025-05-04T12:30:00.000Z",
  "updated_at": "2025-05-04T12:30:00.000Z",
  "url": "https://meine-piraten.de/tasks/1/comments/1.json"
}
```

---

## Database Schema

### tasks

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| title | string | required, max 200 characters |
| description | text | max 2000 characters |
| completed | boolean | |
| creator_name | string | |
| time_needed_in_hours | integer | |
| activity_points | integer | |
| category_id | integer | not null, foreign key → categories |
| entity_id | integer | not null, foreign key → entities |
| assignee_id | integer | nullable, foreign key → users |
| due_date | date | |
| urgent | boolean | |
| status | string | default: "open", validated: open/claimed/completed/done |
| created_at | datetime | not null |
| updated_at | datetime | not null |

### messages

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| sender_id | integer | not null, foreign key → users |
| recipient_id | integer | not null, foreign key → users |
| body | text | not null (validated) |
| read | boolean | not null, default: false |
| created_at | datetime | not null |
| updated_at | datetime | not null |

### push_subscriptions

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| token | string | not null, unique (APNs device token) |
| platform | string | not null, default: "ios" |
| user_id | integer | not null, foreign key → users |
| messages_enabled | boolean | not null, default: false |
| todos_enabled | boolean | not null, default: false |
| forum_enabled | boolean | not null, default: false |
| news_enabled | boolean | not null, default: false |
| created_at | datetime | not null |
| updated_at | datetime | not null |

### entities

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| name | string | |
| LV | boolean | Landesverband flag |
| OV | boolean | Ortsverband flag |
| KV | boolean | Kreisverband flag |
| entity_id | integer | self-referencing parent entity |
| created_at | datetime | not null |
| updated_at | datetime | not null |

### categories

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| name | string | |
| created_at | datetime | not null |
| updated_at | datetime | not null |

### comments

| Column | Type | Constraints |
|--------|------|-------------|
| id | integer | primary key, auto-increment |
| task_id | integer | not null, foreign key → tasks |
| author_name | string | |
| text | text | required (validated) |
| created_at | datetime | not null |
| updated_at | datetime | not null |

---

## Push Notification Payloads

Push notifications are delivered via APNs (HTTP/2) using the `apnotic` gem. Payloads never contain PII — only generic German alert text and routing data.

| Event | Alert body | deepLink | Extra fields |
|-------|-----------|----------|-------------|
| New message | "Du hast eine neue Nachricht" | `"message"` | `topicId` |
| Todo updated | "Ein ToDo wurde aktualisiert" | `"todo"` | `todoId` |
| New forum post | "Es gibt neue Beiträge im Forum" | `"forum"` | — |
| New news item | "Es gibt neue Neuigkeiten" | `"forum"` | — |

The `badge` count reflects the recipient's unread message count.

---

## Notes

- The `entity_id` field on the entities table is a self-referencing foreign key for hierarchical organization (e.g. a Kreisverband belongs to a Landesverband).
- The `LV`, `OV`, `KV` boolean flags on entities indicate the organizational level type.
- All JSON responses from `/tasks`, `/entities`, `/categories`, `/comments` include a `url` field with the resource's canonical URL.
- The root path (`/`) maps to `tasks#index`.
