# Apna Products (Offline-First)

Flutter assignment app: paginated products from Apna Softwares Billbook API with offline cache, favorites, and sync queue.

## Setup

```bash
flutter pub get
dart run build_runner build
flutter run
```

## Architecture

```
lib/
  core/           # API constants, Dio, errors
  domain/         # entities, repository contracts, use cases
  data/           # Drift DB, datasources, repository impl
  services/       # connectivity, sync queue, pagination helper
  presentation/   # GetX bindings, controllers, UI
```

**Flow**

- Online: API → local Drift DB → UI (cache expires after 10 minutes per page)
- Offline: Drift only
- Favorites: instant UI update → local `favorites` + `sync_queue` → auto sync on reconnect

**Drift tables**

| Table | Purpose |
|-------|---------|
| products | Cached product rows per page |
| favorites | Local favorite flags |
| page_caches | Which pages are fetched + expiry metadata |
| sync_queue | Pending FAVORITE_ADD / FAVORITE_REMOVE actions |

## Stack

GetX, Dio, Drift, connectivity_plus
