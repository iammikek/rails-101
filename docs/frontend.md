# Catalog Shop frontend

This document explains how the **browser UI** at `/shop` was built — a classic Rails full-stack frontend that sits alongside the JSON API, not a JavaScript client calling `/items`.

---

## Two interfaces, one database

| | JSON API | Catalog Shop (`/shop`) |
|--|----------|------------------------|
| Response | `application/json` | `text/html` |
| Auth | JWT Bearer token | Session cookie |
| Routes | `config/routes.rb` (API paths) | `/shop/*` + session |
| Views | — | ERB in `app/views/shop/` |
| Validation | Controllers | Controllers + HTML forms |

The shop calls **`ItemService` and `UserService` directly** — it does not HTTP-call `/items`. Same monolith pattern as laravel-101, django-101, and symfony-101.

---

## Architecture

```
/shop/*  ──► Shop::*Controller  ──► form params in controller
                                    │
                                    ▼
                              *Service  ──► ActiveRecord  ──► DB

/items   ──► ItemsController  ──► (same) ItemService  ──► DB
```

---

## Shop URLs

| URL | Controller | Auth | Purpose |
|-----|------------|------|---------|
| `/shop` | `Shop::HomeController` | Public | Landing + catalog stats |
| `/shop/items` | `Shop::ItemsController#index` | Public | Browse/filter items |
| `/shop/items/:id` | `Shop::ItemsController#show` | Public | Item detail |
| `/shop/items/new` | `Shop::ItemsController#new/create` | Session | Add item via HTML form |
| `/shop/register` | `Shop::AuthController#register` | Public | Signup + auto-login |
| `/shop/login` | `Shop::AuthController#login` | Public | Session login |
| `/shop/logout` | `Shop::AuthController#logout` | POST | End session |

Header **API** link → `GET /items` (raw JSON in the browser).

---

## Dual auth

| Action | Shop (browser) | API (JSON) |
|--------|----------------|------------|
| Register | `POST /shop/register` → session | `POST /auth/register` → user JSON |
| Login | `POST /shop/login` → session cookie | `POST /auth/login` → JWT |
| Write items | Session on `/shop/items/new` | `POST /items` with Bearer token |
