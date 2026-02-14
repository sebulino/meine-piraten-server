# meine-piraten.de API Overview

## General

- **Base URL:** `https://meine-piraten.de` (production) / `http://localhost:3000` (development)
- **Format:** JSON (append `.json` to endpoints or use `Accept: application/json`)
- **Authentication:** None (current state — no auth layer)
- **Framework:** Rails 8.0.2 with jbuilder for JSON serialization
- **Database:** SQLite3

---

## Resources

### Tasks

A task represents an actionable item assigned to an organizational entity and category.

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/tasks.json` | List all tasks |
| GET | `/tasks/:id.json` | Get a single task |
| POST | `/tasks.json` | Create a task |
| PATCH/PUT | `/tasks/:id.json` | Update a task |
| DELETE | `/tasks/:id.json` | Delete a task |

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
    "status": "string (optional, one of: open, claimed, done; default: open; see status transitions below)",
    "assignee": "string (optional)"
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
  "creator_name": "Max Mustermann",
  "time_needed_in_hours": 2,
  "due_date": "2025-06-01",
  "urgent": true,
  "activity_points": 10,
  "category_id": 1,
  "entity_id": 1,
  "status": "open",
  "assignee": null,
  "created_at": "2025-05-04T12:00:00.000Z",
  "updated_at": "2025-05-04T12:00:00.000Z",
  "url": "https://meine-piraten.de/tasks/1.json"
}
```

#### Response Shape (list)

```json
[
  { "id": 1, "title": "...", ... },
  { "id": 2, "title": "...", ... }
]
```

#### Status Transitions

Task status follows a strict state machine. Invalid transitions return **422 Unprocessable Entity**.

| From | Allowed transitions |
|------|-------------------|
| `open` | `claimed` |
| `claimed` | `done`, `open` |
| `done` | *(none — terminal state)* |

For example, a task cannot go directly from `open` to `done`; it must first be `claimed`.

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
  "author_name": "Max Mustermann",
  "text": "Flyer sind bestellt.",
  "created_at": "2025-05-04T12:30:00.000Z",
  "updated_at": "2025-05-04T12:30:00.000Z",
  "url": "https://meine-piraten.de/tasks/1/comments/1.json"
}
```

#### Response Shape (list)

```json
[
  { "id": 1, "task_id": 1, "author_name": "...", "text": "...", ... },
  { "id": 2, "task_id": 1, "author_name": "...", "text": "...", ... }
]
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
| due_date | date | |
| urgent | boolean | |
| status | string | default: "open", validated: open/claimed/done |
| assignee | string | nullable |
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

## Notes

- **No authentication** is currently implemented. All endpoints are publicly accessible.
- The `entity_id` field on the entities table is a self-referencing foreign key for hierarchical organization (e.g. a Kreisverband belongs to a Landesverband).
- The `LV`, `OV`, `KV` boolean flags on entities indicate the organizational level type.
- All JSON responses include a `url` field with the resource's canonical URL.
- The root path (`/`) maps to `tasks#index`.
