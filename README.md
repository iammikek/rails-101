# Getting Fast at Rails

A step-by-step **Rails 8 + ActiveRecord** port of [fastAPI-101](https://github.com/iammikek/fastAPI-101) — same items/categories API, same crossover style as [laravel-101](https://github.com/iammikek/laravel-101), native Rails conventions.

**Audience:** Rails developers learning the *-101 family API shape, or Laravel/Django/Symfony devs comparing how Rails does the same monolith split.

**Monolith UI:** Rails owns the JSON API plus a **server-rendered shop** at `/shop` (ERB + session auth) — see **[docs/frontend.md](docs/frontend.md)**.

---

## What's Included

1. **Rails 8.0** — API routes without `/api` prefix (matches laravel-101 / symfony-101 URLs)
2. **`User` model** — register/login/me, JWT (`jwt` gem + `has_secure_password`)
3. **`Category` + `Item` models** — ActiveRecord, migrations, service layer
4. **Service layer** — `app/services/` (mirrors laravel-101)
5. **Pagination** — `{ items, total, skip, limit }`
6. **Filtering** — `min_price`, `max_price`, `category_id`, `name_contains`
7. **Item stats** — `GET /items/stats/summary`
8. **JWT auth** — Bearer tokens on write endpoints
9. **Rate limiting** — 10/min auth, 60/min writes (`rack-attack`)
10. **Catalog Shop** — ERB UI at `/shop` — **[docs/frontend.md](docs/frontend.md)**
11. **SQLite locally** — PostgreSQL in Docker (port **8012**)
12. **Tests** — Minitest integration tests
13. **CI** — GitHub Actions

---

## Quick Start

### Local Ruby (SQLite)

```bash
cd rails-101
cp .env.example .env   # optional
bundle install
bin/rails db:prepare
make serve
```

Open **http://127.0.0.1:8012/** — hello message  
**http://127.0.0.1:8012/items** — JSON list  
**http://127.0.0.1:8012/shop** — browser UI

### Docker (PostgreSQL)

```bash
docker compose up --build
```

API on **http://localhost:8012** (flask-101 = 8011, laravel-101 = 8003, django-101 = 8001).

### Tests

```bash
bundle install
bin/rails db:prepare
bin/rails test
```

---

## Project Structure

```
rails-101/
├── app/
│   ├── controllers/          # JSON API
│   ├── controllers/shop/     # ERB shop (/shop)
│   ├── models/               # User, Category, Item
│   ├── services/             # Business logic
│   ├── serializers/          # ApiSerializer
│   └── models/errors.rb      # Domain errors

├── app/views/shop/           # ERB templates
├── public/shop/style.css
├── config/routes.rb          # JWT API + shop routes
├── docs/frontend.md
└── test/integration/         # Minitest
```

---

## Catalog Shop (`/shop`)

| Shop (browser) | API (JSON) |
|----------------|------------|
| `/shop/register` — signup + auto-login | `POST /auth/register` |
| `/shop/login` — session cookie | `POST /auth/login` — JWT |
| `/shop/items` — HTML table + filters | `GET /items` |
| `/shop/items/new` — HTML form | `POST /items` — Bearer token |

The shop calls **`ItemService` / `UserService` directly** — it does not fetch `/items`.

- **ERB views** in `app/views/shop/`
- **Session auth** on shop writes; **JWT** on API writes
- Header **API** link → raw JSON at `/items`

```bash
make serve
# http://127.0.0.1:8012/shop/register
curl -I http://127.0.0.1:8012/shop/style.css   # Content-Type: text/css
```

Full walkthrough: **[docs/frontend.md](docs/frontend.md)**

---

## Quick Reference

| Goal | Command |
|------|---------|
| Install deps | `bundle install` |
| Migrate | `bin/rails db:prepare` |
| Run local | `make serve` → http://127.0.0.1:8012 |
| Open shop | http://127.0.0.1:8012/shop |
| Raw JSON items | http://127.0.0.1:8012/items |
| Run tests | `bin/rails test` |
| Docker | `docker compose up --build` |

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

## Laravel ↔ Rails map

| laravel-101 | rails-101 |
|-------------|-----------|
| Eloquent | ActiveRecord |
| Blade | ERB |
| `app/Services/` | `app/services/` |
| `jwt-auth` | `jwt` gem + `JwtService` |
| `throttle:` | `rack-attack` |
| `php artisan serve --port=8003` | `rails server -p 8012` |
| PHPUnit | Minitest |

Same API response shapes. Same `/shop` monolith pattern.

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
\* go-101 also uses port 8000 — run one backend at a time, or change port in config.

### Other clients

| Repo | Platform | Stack |
|------|----------|-------|
| [flutter-101](https://github.com/iammikek/flutter-101) | Mobile / desktop | Flutter (iOS, macOS, Android) |
| [react-101](https://github.com/iammikek/react-101) | Web browser | React 19, Vite, Vitest |
| [vue-101](https://github.com/iammikek/vue-101) | Web browser | Vue 3, Vite, Pinia |
| [alpine-101](https://github.com/iammikek/alpine-101) | Web browser | Alpine.js, Vite, Vitest |

### Suggested pairing

- **Compare monolith stacks:** [laravel-101](https://github.com/iammikek/laravel-101) (8003), [django-101](https://github.com/iammikek/django-101) (8001), rails-101 (8012)
- **From Rails to API-only:** rails-101 (8012) → [fastAPI-101](https://github.com/iammikek/fastAPI-101) (8000) or [nest-101](https://github.com/iammikek/nest-101) (8006)
- **Pair with a client:** [react-101](https://github.com/iammikek/react-101), [vue-101](https://github.com/iammikek/vue-101), [alpine-101](https://github.com/iammikek/alpine-101), or [flutter-101](https://github.com/iammikek/flutter-101)

Catalogue: [automica.io/learning-101](https://automica.io/learning-101.html)
