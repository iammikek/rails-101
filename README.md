# Getting Fast at Rails

A step-by-step **Rails 8 + ActiveRecord** port of [fastAPI-101](https://github.com/iammikek/fastAPI-101) — same items/categories API, same Laravel crossover style as [django-101](https://github.com/iammikek/django-101) and [laravel-101](https://github.com/iammikek/laravel-101), different framework.

**Audience:** Laravel developers learning Rails (or comparing how Rails does the same monolith split).

**Monolith:** Rails owns models, migrations, JSON API, and a **server-rendered shop** at `/shop` (ERB + session auth) — not a frontend that HTTP-calls its own `/items` API. See **[docs/frontend.md](docs/frontend.md)**.

---

## What's Included

1. **Rails 8 project** with routes, controllers, health endpoints
2. **`User` model** — email login, `has_secure_password`, register/login/me, JWT
3. **`Category` + `Item` models** — ActiveRecord, migrations, service layer
4. **Service layer** — `app/services/` (mirrors laravel-101 / fastAPI-101 business logic)
5. **Pagination** — `{ items, total, skip, limit }` (same shape as FastAPI Step 20)
6. **Filtering** — `min_price`, `max_price`, `category_id`, `name_contains` on `GET /items`
7. **Item stats** — `GET /items/stats/summary` with per-category breakdown
8. **JWT auth** — Bearer tokens on write endpoints (`jwt` gem + `JwtService`)
9. **Rate limiting** — 10/min auth, 60/min writes (`rack-attack`)
10. **PostgreSQL in Docker** — port **8012** (laravel-101 keeps **8003**)
11. **Catalog Shop** — server-rendered HTML at `/shop` — **[docs/frontend.md](docs/frontend.md)**
12. **Tests** — Minitest integration tests (23)
13. **CI** — GitHub Actions

**Related learning projects:** See [*-101 Family](#-101-family) for the full catalogue.

By the end, you can start the API with one command and browse the same domain through JSON **or** ERB.

---

## Table of Contents

1. [Quick Start](#1-quick-start)
2. [Project Structure](#2-project-structure)
3. [Laravel ↔ Rails map](#3-laravel--rails-map)
4. [Step 1: Project setup](#4-step-1-project-setup)
5. [Step 2: Gemfile dependencies](#5-step-2-gemfile-dependencies)
6. [Step 3: Models + migrations](#6-step-3-models--migrations)
7. [Step 4: Routes (no `/api` prefix)](#7-step-4-routes-no-api-prefix)
8. [Step 5: Controllers + ApiSerializer](#8-step-5-controllers--apiserializer)
9. [Step 6: Service layer](#9-step-6-service-layer)
10. [Step 7: Filtering + pagination](#10-step-7-filtering--pagination)
11. [Step 8: Item stats](#11-step-8-item-stats)
12. [Step 9: JWT authentication](#12-step-9-jwt-authentication)
13. [Step 10: Rate limiting](#13-step-10-rate-limiting)
14. [Step 11: Tests + CI](#14-step-11-tests--ci)
15. [Step 12: PostgreSQL (Docker)](#15-step-12-postgresql-docker)
16. [Step 13: Catalog Shop](#16-step-13-catalog-shop)
17. [Quick Reference](#17-quick-reference)
18. [Compare with laravel-101](#18-compare-with-laravel-101)
19. [*-101 Family](#-101-family)

---

## 1. Quick Start

**Pick one:** Docker **or** local Rails — both use port **8012**, so don't run them at the same time.

### Option A: Local Ruby (SQLite)

```bash
cd rails-101
cp .env.example .env   # optional
bundle install
bin/rails db:prepare
make serve
```

Open:

- **http://127.0.0.1:8012/** — root message
- **http://127.0.0.1:8012/items** — item list JSON
- **http://127.0.0.1:8012/shop** — browser UI (register, browse, add items)

### Option B: Docker (PostgreSQL)

```bash
docker compose up --build
```

API on **http://localhost:8012** (laravel-101 = 8003, django-101 = 8001, fastAPI-101 = 8000).

### Tests

```bash
bundle install
bin/rails db:prepare
bin/rails test
```

**Note:** Local Rails uses **SQLite** (`storage/development.sqlite3`). **Docker Compose** uses **PostgreSQL** (Step 12).

---

## 2. Project Structure

```
rails-101/
├── app/
│   ├── controllers/              # JSON API (Laravel Http/Controllers)
│   │   ├── api_controller.rb     # JSON base + error rescue
│   │   ├── auth_controller.rb
│   │   ├── items_controller.rb
│   │   ├── categories_controller.rb
│   │   ├── health_controller.rb
│   │   ├── concerns/jwt_authenticatable.rb
│   │   └── shop/                 # ERB shop (/shop)
│   ├── models/                   # User, Category, Item + Errors
│   ├── services/                 # Business logic (shared by API + shop)
│   ├── serializers/api_serializer.rb
│   └── views/shop/               # ERB templates
├── config/
│   ├── routes.rb                 # API + shop (no /api prefix)
│   ├── database.yml
│   └── initializers/rack_attack.rb
├── db/migrate/                   # Schema (Laravel database/migrations)
├── public/shop/style.css
├── docs/frontend.md
├── test/integration/             # Minitest (Laravel tests/Feature)
├── Gemfile
├── Dockerfile
├── docker-compose.yml
├── Makefile
└── README.md
```

**Laravel parallel:** `app/Http/Controllers` ↔ `app/controllers`, `app/Models` ↔ `app/models`, `app/Services` ↔ `app/services`, `routes/api.php` + `routes/web.php` ↔ one `config/routes.rb`.

---

## 3. Laravel ↔ Rails map

| laravel-101 | rails-101 |
|-------------|-----------|
| `artisan serve --port=8003` | `rails server -p 8012` / `make serve` |
| `composer.json` | `Gemfile` + `bundle install` |
| Eloquent | ActiveRecord |
| `php artisan migrate` | `bin/rails db:migrate` / `db:prepare` |
| Blade | ERB |
| `app/Services/` | `app/services/` |
| `ApiSerializer` | `ApiSerializer` (same JSON shapes) |
| `jwt-auth` | `jwt` gem + `JwtService` |
| `auth:api` middleware | `before_action :authenticate_jwt!` |
| `Hash::make` / `Hash::check` | `has_secure_password` (bcrypt) |
| `throttle:10,1` | `rack-attack` |
| PHPUnit Feature tests | Minitest integration tests |
| Session shop on `web` routes | Session shop under `/shop` |

| FastAPI concept | Rails equivalent |
|-----------------|------------------|
| `APIRouter` | `config/routes.rb` + controllers |
| Pydantic schemas | Controller params + `ApiSerializer` |
| SQLAlchemy models | ActiveRecord |
| Alembic | `db/migrate` |
| `Depends(get_current_user)` | `JwtAuthenticatable` concern |
| `slowapi` | `rack-attack` |
| pytest + TestClient | Minitest + `ActionDispatch::IntegrationTest` |

Same API response shapes. Same `/shop` monolith pattern as laravel-101.

---

## 4. Step 1: Project setup

```bash
rails new . --database=sqlite3 --skip-javascript --skip-hotwire --skip-jbuilder
bundle install
bin/rails db:prepare
```

**What Rails gives you:** `app/`, `config/`, `db/`, `bin/rails`, Puma, Propshaft, Minitest.

**Laravel parallel:** `laravel new` + `composer install` + `php artisan key:generate`.

Rails generates a secret key for development automatically. Docker sets `SECRET_KEY_BASE` explicitly (see `docker-compose.yml`).

---

## 5. Step 2: Gemfile dependencies

**What it is:** Ruby's `composer.json` / `requirements.txt`. Bundler installs everything with `bundle install`.

| Gem | Purpose | Laravel parallel |
|-----|---------|------------------|
| `rails` | Framework | `laravel/framework` |
| `sqlite3` / `pg` | Databases | SQLite / `pgsql` |
| `puma` | App server | `php artisan serve` / Octane |
| `bcrypt` | Password hashing | `Hash` facade |
| `jwt` | Sign/verify Bearer tokens | `php-open-source-saver/jwt-auth` |
| `rack-attack` | Rate limiting | `throttle:` middleware |

**Copy-paste focus (`Gemfile`):**

```ruby
gem "rails", "~> 8.0.2"
gem "sqlite3", ">= 2.1"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "bcrypt", "~> 3.1.7"
gem "jwt", "~> 2.9"
gem "rack-attack", "~> 6.7"
```

---

## 6. Step 3: Models + migrations

**`db/migrate/..._create_catalog_tables.rb`** creates `users`, `categories`, and `items`.

**`app/models/item.rb`:**

```ruby
class Item < ApplicationRecord
  belongs_to :category, optional: true

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
end
```

**`app/models/user.rb`** — email-only login (no `name` column), matching the *-101 API:

```ruby
class User < ApplicationRecord
  has_secure_password   # password_digest + authenticate

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8, maximum: 128 }, if: -> { password.present? }
end
```

```bash
bin/rails db:migrate
```

**Laravel parallel:**

| Laravel | Rails |
|---------|-------|
| `php artisan make:model Item -m` | migration file + `app/models/item.rb` |
| `$fillable` | mass-assignment via strong params / service kwargs |
| `belongsTo(Category::class)` | `belongs_to :category` |
| `'password' => 'hashed'` cast | `has_secure_password` |

---

## 7. Step 4: Routes (no `/api` prefix)

**`config/routes.rb`** registers the same URLs as laravel-101 / symfony-101 — **no** `/api` prefix.

| Method | Path | Auth |
|--------|------|------|
| GET | `/`, `/health` | Public |
| POST | `/auth/register`, `/auth/login` | Public (rate-limited) |
| GET | `/auth/me` | JWT |
| GET | `/items`, `/items/:id`, `/items/stats/summary` | Public |
| POST/PATCH/DELETE | `/items...` | JWT |
| GET | `/categories`, `/categories/:id` | Public |
| POST/PATCH/DELETE | `/categories...` | JWT |
| * | `/shop...` | Session on writes |

**Laravel parallel:** `routes/api.php` with `apiPrefix: ''` + `routes/web.php` for `/shop`.

```ruby
# JSON writes
post "/items", to: "items#create"
# Shop (session)
scope path: "/shop", as: "shop", module: "shop" do
  get "/items/new", to: "items#new"
  post "/items/new", to: "items#create"
end
```

---

## 8. Step 5: Controllers + ApiSerializer

Controllers stay thin: parse params, call a service, render JSON.

**`ApiController`** skips CSRF (JSON clients) and maps domain errors to `{ detail, code }`:

```ruby
class ApiController < ApplicationController
  skip_forgery_protection

  rescue_from ::Errors::AppError do |error|
    render json: { detail: error.message, code: error.code }, status: error.status
  end
end
```

**`ApiSerializer`** keeps response shapes identical to laravel-101:

```ruby
ApiSerializer.item(item)
# => { id, name, description, price, category_id, category: { id, name, description } | null }

ApiSerializer.user(user)
# => { id, email }
```

**Laravel parallel:** `ItemController` + `ApiSerializer::item($item)`.

---

## 9. Step 6: Service layer

Business rules live in **`app/services/`** so the JSON API and the ERB shop share one implementation.

| Service | Responsibility |
|---------|----------------|
| `ItemService` | list/filter/paginate, CRUD, stats |
| `CategoryService` | CRUD, unique name, block delete-in-use |
| `UserService` | register, authenticate |
| `JwtService` | encode/decode Bearer tokens |

Examples:

- Duplicate category name → **409** `CATEGORY_NAME_EXISTS`
- Delete category with items → **409** `CATEGORY_IN_USE`
- Missing item/category → **404** `ITEM_NOT_FOUND` / `CATEGORY_NOT_FOUND`
- Duplicate email → **409** `USER_EMAIL_EXISTS`

**Laravel parallel:** `app/Services/ItemService.php` — same method names, same status codes.

---

## 10. Step 7: Filtering + pagination

`GET /items?min_price=10&category_id=1&name_contains=widget&skip=0&limit=10`

Implemented in `ItemService#list_items` / `#apply_filters`:

```ruby
scope = scope.where("price >= ?", filters[:min_price]) if filters[:min_price]
scope = scope.where("LOWER(name) LIKE ?", "%#{filters[:name_contains].downcase}%") if filters[:name_contains]
```

**Pagination response** (same as fastAPI-101 Step 20):

```json
{
  "items": [ ... ],
  "total": 42,
  "skip": 0,
  "limit": 10
}
```

`skip` ≥ 0, `limit` clamped to 1–100.

**Laravel parallel:** query builders + `skip`/`take` with the same JSON envelope.

---

## 11. Step 8: Item stats

`GET /items/stats/summary`:

```json
{
  "total_items": 5,
  "average_price": 12.5,
  "min_price": 5.0,
  "max_price": 20.0,
  "uncategorized_count": 1,
  "by_category": [
    { "category_id": 1, "category_name": "Tools", "item_count": 2, "average_price": 10.0 }
  ]
}
```

Logic in `ItemService#stats` — ActiveRecord aggregates (`AVG` / `MIN` / `MAX` / `GROUP BY`), same capstone as laravel-101.

---

## 12. Step 9: JWT authentication

| Endpoint | Purpose |
|----------|---------|
| `POST /auth/register` | `{ email, password }` → **201** `{ id, email }` |
| `POST /auth/login` | `username` **or** `email` + `password` → `{ access_token, token_type: "bearer" }` |
| `GET /auth/me` | Bearer required → `{ id, email }` |

Write endpoints on `/items` and `/categories` require:

```http
Authorization: Bearer <access_token>
```

**How it wires:**

| Piece | Role |
|-------|------|
| `has_secure_password` | Hash + verify passwords |
| `JwtService.encode/decode` | HS256 JWT (`JWT_SECRET` or `secret_key_base`) |
| `JwtAuthenticatable` | `before_action :authenticate_jwt!` |

**Laravel parallel:**

| Laravel | Rails |
|---------|-------|
| `JWTAuth::fromUser($user)` | `JwtService.encode(user)` |
| `auth:api` | `authenticate_jwt!` |
| `username` = email on login | same (FastAPI / OAuth2 form parity) |

**Try it:**

```bash
# Register
curl -X POST http://127.0.0.1:8012/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"you@example.com","password":"password123"}'

# Login (form-style username=email, or JSON email)
curl -X POST http://127.0.0.1:8012/auth/login \
  -d 'username=you@example.com&password=password123'

# Create item
curl -X POST http://127.0.0.1:8012/items \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Widget","price":9.99}'
```

---

## 13. Step 10: Rate limiting

**`config/initializers/rack_attack.rb`** + `config.middleware.use Rack::Attack`.

| Endpoint group | Limit |
|----------------|-------|
| `POST /auth/register`, `POST /auth/login` | 10/minute per IP |
| POST/PATCH/DELETE on `/items` and `/categories` | 60/minute per IP |

Shop HTML POSTs are **excluded** (session forms are not the JSON write surface).

**429 response:**

```json
{ "detail": "Rate limit exceeded", "code": "RATE_LIMIT_EXCEEDED" }
```

**Laravel parallel:** `Route::middleware('throttle:10,1')` and `throttle:60,1`.

---

## 14. Step 11: Tests + CI

**`test/integration/`** — Minitest feature-style tests:

| File | Covers |
|------|--------|
| `health_test.rb` | `/`, `/health` |
| `auth_test.rb` | register, login, `/auth/me` |
| `items_test.rb` | CRUD, filters, pagination, stats |
| `categories_test.rb` | CRUD, duplicate name, in-use delete |
| `shop_test.rb` | ERB home, register → create item, auth gate |

```bash
bin/rails test
# 23 runs
```

**CI:** `.github/workflows/ci.yml` — Ruby 3.3, `db:prepare`, `bin/rails test`.

**Laravel parallel:** `tests/Feature/*Test.php` + `php artisan test`.

Helper pattern (like laravel-101's `ApiTestCase`):

```ruby
class ApiTestCase < ActionDispatch::IntegrationTest
  def create_authenticated_token(...)
    # register user → JwtService.encode
  end
end
```

---

## 15. Step 12: PostgreSQL (Docker)

```bash
docker compose up --build
```

| Service | Role |
|---------|------|
| `database` | Postgres 16 on host port **5436** |
| `api` | Rails on host port **8012** → container 8000 |

Migrations run on startup (`bin/rails db:prepare`).

`DATABASE_URL=postgres://app:app@database:5432/app` switches ActiveRecord from SQLite to Postgres (`config/database.yml`).

Local `make serve` still uses SQLite.

**Laravel parallel:** Compose `pgsql` + `php artisan migrate --force` on boot.

---

## 16. Step 13: Catalog Shop

A **Catalog Shop** at `/shop` demonstrates full-stack Rails alongside the JSON API:

| Shop (browser) | API (JSON) |
|----------------|------------|
| `/shop/register` — signup + auto-login | `POST /auth/register` |
| `/shop/login` — session cookie | `POST /auth/login` — JWT |
| `/shop/items` — HTML table + filters | `GET /items` |
| `/shop/items/new` — HTML form | `POST /items` — Bearer token |

The shop calls **`ItemService` / `UserService` directly** — it does not HTTP-call `/items`. Same monolith pattern as Laravel web routes using Eloquent, not internal HTTP.

| | JSON API | Catalog Shop |
|--|----------|--------------|
| Response | `application/json` | `text/html` (ERB) |
| Auth | JWT Bearer | Session (`session[:user_id]`) |
| Controllers | `ItemsController`, … | `Shop::ItemsController`, … |

**Full walkthrough:** **[docs/frontend.md](docs/frontend.md)**

```bash
make serve
# http://127.0.0.1:8012/shop/register
curl -I http://127.0.0.1:8012/shop/style.css   # text/css
```

**Laravel parallel:** Blade shop at `/shop` + `Shop\*Controller` — ERB fills the same role as Blade.

---

## 17. Quick Reference

| Goal | Command |
|------|---------|
| Install deps | `bundle install` |
| Migrate | `bin/rails db:prepare` |
| Run local (SQLite) | `make serve` → http://127.0.0.1:8012 |
| Open shop UI | http://127.0.0.1:8012/shop |
| Raw JSON items | http://127.0.0.1:8012/items |
| Frontend docs | [docs/frontend.md](docs/frontend.md) |
| Run tests | `bin/rails test` |
| Docker + Postgres | `docker compose up --build` |
| Stop Docker | `docker compose down` |
| Rails console | `bin/rails console` |

### API endpoints

| Path | Method | Auth | Purpose |
|------|--------|------|---------|
| `/` | GET | — | Hello message |
| `/health` | GET | — | Health check |
| `/auth/register` | POST | — | Create user |
| `/auth/login` | POST | — | Get JWT |
| `/auth/me` | GET | JWT | Current user |
| `/categories` | GET/POST | JWT on POST | List/create |
| `/categories/{id}` | GET/PATCH/DELETE | JWT on writes | CRUD |
| `/items` | GET/POST | JWT on POST | List/create |
| `/items/stats/summary` | GET | — | Statistics |
| `/items/{id}` | GET/PATCH/DELETE | JWT on writes | CRUD |

---

## 18. Compare with laravel-101

Run both side by side:

| | laravel-101 | rails-101 |
|--|-------------|-----------|
| Port (local/Docker) | 8003 | 8012 |
| Root message | `Hello from laravel-101` | `Hello from rails-101` |
| API shape | Same endpoints | Same endpoints |
| ORM | Eloquent | ActiveRecord |
| Shop views | Blade | ERB |
| API auth | jwt-auth | `jwt` + `JwtService` |
| Session shop | `web` + `auth` | `/shop` + session |
| Tests | 28 PHPUnit | 23 Minitest |

You now have the **same API + shop** implemented twice — once Laravel, once Rails. That is the crossover for PHP developers moving into Ruby.

---

## *-101 Family

### API backends

| Repo | Port | Type | Stack |
|------|------|------|-------|
| [fastAPI-101](https://github.com/iammikek/fastAPI-101) | 8000 | API-only | FastAPI, SQLAlchemy |
| [django-101](https://github.com/iammikek/django-101) | 8001 | Monolith | Django + DRF + shop |
| [symfony-101](https://github.com/iammikek/symfony-101) | 8002 | Monolith | Symfony + shop |
| [laravel-101](https://github.com/iammikek/laravel-101) | 8003 | Monolith | Laravel + shop |
| [framework-x-101](https://github.com/iammikek/framework-x-101) | 8004 | Monolith | Framework X + shop |
| [orchestr-101](https://github.com/iammikek/orchestr-101) | 8005 | Monolith | Orchestr + shop |
| [nest-101](https://github.com/iammikek/nest-101) | 8006 | API-only | NestJS, TypeScript |
| [express-101](https://github.com/iammikek/express-101) | 8007 | API-only | Express, Vitest |
| [go-101](https://github.com/iammikek/go-101) | 8000* | API-only | Gin, GORM |
| [fortran-101](https://github.com/iammikek/fortran-101) | 8008 | API-only | Fortran, fpm |
| [java-101](https://github.com/iammikek/java-101) | 8009 | API-only | Spring Boot, JPA, Flyway |
| [dotNet-101](https://github.com/iammikek/dotNet-101) | 8010 | API-only | ASP.NET Core, xUnit |
| [flask-101](https://github.com/iammikek/flask-101) | 8011 | API-only | Flask, pytest |
| [**rails-101**](https://github.com/iammikek/rails-101) | **8012** | Monolith | Rails + shop |
| [geblang-101](https://github.com/iammikek/geblang-101) | 8013 | API-only | Geblang, SQLite |
| [gebweb-101](https://github.com/iammikek/gebweb-101) | 8014 | API-only | Geblang + Gebweb |
| [sinatra-101](https://github.com/iammikek/sinatra-101)           | 8015  | API-only | Sinatra, RSpec               |
\* go-101 also uses port 8000 — run one backend at a time, or change port in config.

### Other clients

| Repo | Platform | Stack |
|------|----------|-------|
| [flutter-101](https://github.com/iammikek/flutter-101) | Mobile / desktop | Flutter (iOS, macOS, Android) |
| [react-101](https://github.com/iammikek/react-101) | Web browser | React 19, Vite, Vitest |
| [vue-101](https://github.com/iammikek/vue-101) | Web browser | Vue 3, Vite, Pinia |
| [alpine-101](https://github.com/iammikek/alpine-101) | Web browser | Alpine.js, Vite, Vitest |

### Suggested pairing

- **From Laravel into Rails:** [laravel-101](https://github.com/iammikek/laravel-101) (8003) → rails-101 (8012) — Eloquent/Blade → ActiveRecord/ERB
- **Compare monoliths:** rails-101 (8012), [django-101](https://github.com/iammikek/django-101) (8001), [symfony-101](https://github.com/iammikek/symfony-101) (8002)
- **API-only reference:** [fastAPI-101](https://github.com/iammikek/fastAPI-101) (8000) for the original step-by-step story
- **Pair with a client:** [react-101](https://github.com/iammikek/react-101), [vue-101](https://github.com/iammikek/vue-101), [alpine-101](https://github.com/iammikek/alpine-101), or [flutter-101](https://github.com/iammikek/flutter-101)

Catalogue: [automica.io/learning-101](https://automica.io/learning-101.html)
