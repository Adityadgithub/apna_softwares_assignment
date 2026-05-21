# Apna Products (Offline-First)

Flutter assignment app: paginated products from Apna Softwares Billbook API with offline cache, favorites, and sync queue.

## Setup

```bash
flutter pub get
dart run build_runner build
flutter run
```

## Architecture (simplified)

```
lib/
  core/              # constants, errors, theme
  data/
    api.dart         # HTTP calls
    local_store.dart # all Drift reads/writes
    product_repository.dart  # offline-first logic
    database/        # Drift schema
    models/          # Product, ProductDetail, DTOs
  services/          # connectivity, sync, pagination
  presentation/      # GetX controllers, pages, widgets
```

**Flow**

- Online: API → `LocalStore` → UI (cache expires after 10 minutes per page)
- Offline: `LocalStore` only
- Favorites: instant UI → local DB + sync queue → auto sync on reconnect

**Drift tables**

| Table | Purpose |
|-------|---------|
| products | Cached product rows per page |
| favorites | Local favorite flags |
| page_caches | Which pages are fetched + expiry metadata |
| sync_queue | Pending FAVORITE_ADD / FAVORITE_REMOVE actions |

## Stack

GetX, http, Drift, connectivity_plus
