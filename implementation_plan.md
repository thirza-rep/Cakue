# 🏦 Cakue — Arsitektur & Desain Sistem

> **Catat Keuangan Gue** — Aplikasi pencatatan keuangan pribadi, offline-first, privacy-focused, dengan sync ke Google Drive.

---

## Stack Teknologi

| Layer | Pilihan | Alasan |
|---|---|---|
| **Framework** | Flutter (Dart) | Performa native di iOS & Android, satu codebase |
| **Database Lokal** | SQLite via `drift` (moor) | Type-safe, reactive streams, migration support |
| **State Management** | Riverpod | Compile-safe, testable, skalabel |
| **Arsitektur** | Clean Architecture + MVVM | Separation of concern maksimal |
| **Cloud Sync** | Google Drive API v3 (`appDataFolder`) | Private, tidak tampil di Drive user |
| **DI** | `get_it` + Riverpod | Modular, mudah di-mock saat testing |

---

## 1. Desain Skema Database (ERD Relasional)

### Filosofi Desain
- Setiap tabel memiliki `uuid` sebagai PK global (bukan auto-increment integer) → aman untuk merge data saat sync.
- Kolom `updated_at` + `sync_status` di semua tabel utama → mendukung *delta sync*.
- Soft-delete (`deleted_at`) → data tidak hilang, aman untuk conflict resolution.

---

### Tabel: `currencies`
```sql
CREATE TABLE currencies (
  code        TEXT PRIMARY KEY,        -- 'IDR', 'USD', 'SGD'
  name        TEXT NOT NULL,
  symbol      TEXT NOT NULL,           -- 'Rp', '$'
  decimal_places INTEGER DEFAULT 2,
  is_base     INTEGER DEFAULT 0,       -- 1 = mata uang utama user
  created_at  INTEGER NOT NULL,        -- Unix timestamp ms
  updated_at  INTEGER NOT NULL,
  sync_status TEXT DEFAULT 'synced'    -- 'synced' | 'pending' | 'conflict'
);
```

---

### Tabel: `accounts` (Rekening/Dompet)
```sql
CREATE TABLE accounts (
  uuid         TEXT PRIMARY KEY,
  name         TEXT NOT NULL,           -- 'BCA Utama', 'Dompet Tunai'
  type         TEXT NOT NULL,           -- 'bank' | 'cash' | 'e-wallet' | 'investment' | 'credit'
  currency_code TEXT NOT NULL REFERENCES currencies(code),
  initial_balance REAL DEFAULT 0,
  current_balance REAL DEFAULT 0,       -- Denormalized, di-update via trigger/service
  color        TEXT,                    -- hex '#4CAF50'
  icon         TEXT,                    -- icon identifier
  is_active    INTEGER DEFAULT 1,
  sort_order   INTEGER DEFAULT 0,
  note         TEXT,
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL,
  deleted_at   INTEGER,                 -- soft delete
  sync_status  TEXT DEFAULT 'pending'
);
```

---

### Tabel: `categories` (Berjenjang / Hierarchical)
```sql
CREATE TABLE categories (
  uuid        TEXT PRIMARY KEY,
  parent_uuid TEXT REFERENCES categories(uuid), -- NULL = kategori induk
  name        TEXT NOT NULL,
  type        TEXT NOT NULL,            -- 'income' | 'expense' | 'transfer'
  icon        TEXT,
  color       TEXT,
  is_system   INTEGER DEFAULT 0,        -- 1 = kategori bawaan, tidak bisa dihapus
  sort_order  INTEGER DEFAULT 0,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL,
  deleted_at  INTEGER,
  sync_status TEXT DEFAULT 'pending'
);

-- Contoh hierarki:
-- Makanan & Minuman (parent)
--   ├── Sarapan
--   ├── Makan Siang
--   └── Kopi & Minuman
```

---

### Tabel: `transactions` (Inti Aplikasi)
```sql
CREATE TABLE transactions (
  uuid              TEXT PRIMARY KEY,
  type              TEXT NOT NULL,      -- 'income' | 'expense' | 'transfer'
  account_uuid      TEXT NOT NULL REFERENCES accounts(uuid),
  to_account_uuid   TEXT REFERENCES accounts(uuid), -- hanya untuk transfer
  category_uuid     TEXT REFERENCES categories(uuid),
  amount            REAL NOT NULL,      -- selalu positif
  base_amount       REAL NOT NULL,      -- amount dalam base currency (untuk multi-currency)
  exchange_rate     REAL DEFAULT 1.0,
  currency_code     TEXT NOT NULL REFERENCES currencies(code),
  date              INTEGER NOT NULL,   -- Unix timestamp ms (waktu transaksi)
  note              TEXT,
  merchant          TEXT,               -- nama toko/merchant (dari AI scanner)
  receipt_image_path TEXT,             -- path lokal gambar struk
  tags              TEXT,              -- JSON array: '["makan","kantor"]'
  is_recurring      INTEGER DEFAULT 0,
  recurring_rule_uuid TEXT,            -- FK ke tabel recurring_rules (future)
  created_at        INTEGER NOT NULL,
  updated_at        INTEGER NOT NULL,
  deleted_at        INTEGER,
  sync_status       TEXT DEFAULT 'pending',

  -- Index untuk query cepat
  CHECK (amount > 0),
  CHECK (type IN ('income', 'expense', 'transfer'))
);

CREATE INDEX idx_transactions_date ON transactions(date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_account ON transactions(account_uuid, date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_category ON transactions(category_uuid, date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_sync ON transactions(sync_status) WHERE sync_status != 'synced';
```

---

### Tabel: `monthly_summaries` (Pre-aggregasi Analytics)
```sql
CREATE TABLE monthly_summaries (
  uuid          TEXT PRIMARY KEY,
  account_uuid  TEXT REFERENCES accounts(uuid), -- NULL = semua akun
  category_uuid TEXT REFERENCES categories(uuid), -- NULL = semua kategori
  year_month    TEXT NOT NULL,           -- '2025-08'
  type          TEXT NOT NULL,           -- 'income' | 'expense'
  total_amount  REAL DEFAULT 0,
  tx_count      INTEGER DEFAULT 0,
  base_currency_total REAL DEFAULT 0,
  updated_at    INTEGER NOT NULL,
  sync_status   TEXT DEFAULT 'pending',

  UNIQUE(account_uuid, category_uuid, year_month, type)
);
```

---

### Tabel: `budgets`
```sql
CREATE TABLE budgets (
  uuid           TEXT PRIMARY KEY,
  name           TEXT NOT NULL,
  category_uuid  TEXT REFERENCES categories(uuid), -- NULL = semua kategori
  account_uuid   TEXT REFERENCES accounts(uuid),   -- NULL = semua akun
  amount         REAL NOT NULL,
  period_type    TEXT NOT NULL,          -- 'monthly' | 'weekly' | 'yearly' | 'custom'
  start_date     INTEGER,
  end_date       INTEGER,
  currency_code  TEXT NOT NULL,
  alert_threshold REAL DEFAULT 0.8,     -- alert di 80%
  is_active      INTEGER DEFAULT 1,
  created_at     INTEGER NOT NULL,
  updated_at     INTEGER NOT NULL,
  deleted_at     INTEGER,
  sync_status    TEXT DEFAULT 'pending'
);
```

---

### Tabel: `sync_log`
```sql
CREATE TABLE sync_log (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name   TEXT NOT NULL,
  record_uuid  TEXT NOT NULL,
  action       TEXT NOT NULL,           -- 'upload' | 'download' | 'conflict'
  drive_file_id TEXT,
  status       TEXT NOT NULL,           -- 'success' | 'failed'
  error_msg    TEXT,
  synced_at    INTEGER NOT NULL
);
```

---

### ERD Visual (Relasi Antar Tabel)

```
currencies ──────────────────────────────────┐
     │                                        │
     │ 1:N                                    │ 1:N
     ▼                                        ▼
  accounts ◄────────── transactions ──────► categories
     │         N:1              N:1 (parent)    │
     │                                          │ (self-referencing)
     │ 1:N                                      ▼
     ▼                                      categories
  budgets                                   (sub-kategori)
     │
     ▼
monthly_summaries (aggregasi dari transactions)
```

---

## 2. Arsitektur Proyek (Clean Architecture + MVVM)

```
lib/
├── core/                          # Fondasi shared
│   ├── constants/
│   ├── errors/                    # Failure classes
│   ├── extensions/
│   ├── network/                   # Connectivity checker
│   └── utils/
│
├── data/                          # Layer DATA
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart  # Drift DB definition
│   │   │   ├── tables/            # Drift table classes
│   │   │   └── daos/              # Data Access Objects per entitas
│   │   └── preferences/           # SharedPreferences
│   ├── remote/
│   │   └── drive/
│   │       ├── drive_api_client.dart
│   │       └── drive_sync_service.dart
│   └── repositories/              # Implementasi repository
│
├── domain/                        # Layer DOMAIN (pure Dart, no Flutter)
│   ├── entities/                  # Model bisnis murni
│   │   ├── account.dart
│   │   ├── transaction.dart
│   │   ├── category.dart
│   │   └── budget.dart
│   ├── repositories/              # Abstract interface
│   └── usecases/                  # Business logic per aksi
│       ├── transactions/
│       │   ├── add_transaction_usecase.dart
│       │   ├── get_transactions_usecase.dart
│       │   └── delete_transaction_usecase.dart
│       ├── analytics/
│       │   └── get_monthly_report_usecase.dart
│       └── sync/
│           └── sync_to_drive_usecase.dart
│
├── presentation/                  # Layer PRESENTASI (MVVM)
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart       # View
│   │   │   └── dashboard_viewmodel.dart    # ViewModel (Riverpod Notifier)
│   │   ├── transactions/
│   │   │   ├── transaction_list_screen.dart
│   │   │   ├── add_transaction_screen.dart
│   │   │   └── transaction_viewmodel.dart
│   │   ├── analytics/
│   │   │   ├── analytics_screen.dart
│   │   │   └── analytics_viewmodel.dart
│   │   └── settings/
│   └── shared/
│       ├── widgets/               # Komponen UI reusable
│       └── theme/                 # Design system (warna, tipografi)
│
└── di/
    └── providers.dart             # Registrasi semua provider Riverpod
```

### Alur Data (Clean Architecture)

```
UI (Screen) → ViewModel → UseCase → Repository Interface
                                          ↓
                               [Local DAO] ←→ [Drive API Client]
```

### Strategi Ekstensibilitas Fitur Masa Depan

| Fitur | Penambahan yang Diperlukan |
|---|---|
| **AI Receipt Scanner** | Tambah `domain/usecases/receipt/scan_receipt_usecase.dart` + integrasi ML Kit/Gemini API di `data/remote/ai/` |
| **Budgeting** | Tabel `budgets` sudah ada, tinggal buat `BudgetRepository` + `BudgetViewModel` |
| **Multi-currency** | Kolom `currency_code`, `base_amount`, `exchange_rate` sudah ada di `transactions` |
| **Recurring Transactions** | Tambah tabel `recurring_rules` + background job scheduler |
| **Export PDF/Excel** | UseCase baru di `domain/usecases/export/` |

---

## 3. Strategi Analitik & Laporan Keuangan

### Masalah
Query `SUM(amount)` pada tabel `transactions` dengan 50.000+ baris → lambat jika dilakukan real-time setiap buka halaman.

### Solusi: 3-Layer Caching Strategy

#### Layer 1: Pre-aggregated `monthly_summaries` Table
- Setiap kali transaksi ditambah/edit/hapus → trigger update `monthly_summaries` secara incremental (bukan re-hitung semua).
- Query dashboard hanya menyentuh `monthly_summaries`, **bukan** tabel `transactions`.

```dart
// Contoh incremental update saat add transaksi
Future<void> _updateMonthlySummary(Transaction tx) async {
  final yearMonth = DateFormat('yyyy-MM').format(tx.date);
  await db.monthlyDao.upsertSummary(
    accountUuid: tx.accountUuid,
    categoryUuid: tx.categoryUuid,
    yearMonth: yearMonth,
    type: tx.type,
    amountDelta: tx.baseAmount,   // +amount untuk add, -amount untuk delete
    countDelta: 1,
  );
}
```

#### Layer 2: In-Memory Cache dengan Riverpod
- `AnalyticsViewModel` meng-cache hasil query terakhir.
- Invalidate cache **hanya** saat ada perubahan transaksi di bulan yang sama.

```dart
// Riverpod provider dengan auto-dispose
final monthlyReportProvider = FutureProvider.autoDispose.family<MonthlyReport, String>(
  (ref, yearMonth) async {
    final useCase = ref.read(getMonthlyReportUseCaseProvider);
    return useCase.execute(yearMonth);
    // Data dari monthly_summaries, bukan raw transactions
  }
);
```

#### Layer 3: Pagination untuk Transaction List
- Tabel `transactions` **hanya** di-query untuk tampilan list, dengan cursor-based pagination.
- Limit 30 item per halaman, load more on scroll.

```dart
Future<List<Transaction>> getTransactions({
  required String accountUuid,
  int limit = 30,
  int? beforeTimestamp,         // cursor
}) {
  return (db.select(db.transactions)
    ..where((t) => t.accountUuid.equals(accountUuid))
    ..where((t) => beforeTimestamp != null 
        ? t.date.isSmallerThan(Variable(beforeTimestamp)) 
        : const Constant(true))
    ..orderBy([(t) => OrderingTerm.desc(t.date)])
    ..limit(limit)
  ).get();
}
```

### Benchmark Query yang Diharapkan

| Query | Data 50K transaksi | Strategi |
|---|---|---|
| Total bulan ini | **< 5ms** | `monthly_summaries` |
| Grafik 12 bulan | **< 10ms** | `monthly_summaries` GROUP BY year_month |
| List transaksi terbaru | **< 20ms** | Indexed + pagination |
| Breakdown per kategori | **< 10ms** | `monthly_summaries` JOIN `categories` |
| Pencarian transaksi | **< 50ms** | FTS5 (Full-Text Search) extension |

---

## 4. Strategi Google Drive Sync

### Mekanisme

```
Offline → Tandai sync_status = 'pending'
Background (WorkManager/BGTask) →
  1. Cek semua record dengan sync_status = 'pending'
  2. Serialize ke JSON per tabel
  3. Upload ke Drive appDataFolder sebagai:
     - cakue_accounts.json
     - cakue_categories.json
     - cakue_transactions_{year_month}.json   ← partisi per bulan
     - cakue_metadata.json                    ← checksums & timestamps
  4. Update sync_status = 'synced'
```

### Conflict Resolution (Last-Write-Wins dengan `updated_at`)

```dart
Future<void> resolveConflict(LocalRecord local, DriveRecord remote) async {
  if (remote.updatedAt > local.updatedAt) {
    await localDao.upsert(remote);  // Remote menang
  }
  // Local menang: tidak perlu action, akan di-upload berikutnya
}
```

---

## 5. Rekomendasi Struktur File Proyek (Segera Mulai)

```
cakue/
├── android/
├── ios/
├── lib/                    (struktur di atas)
├── test/
│   ├── unit/
│   │   ├── usecases/
│   │   └── repositories/
│   └── widget/
├── integration_test/
├── pubspec.yaml
└── README.md
```

### Dependencies Utama (`pubspec.yaml`)

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  drift: ^2.21.0
  sqlite3_flutter_libs: ^0.5.0
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0          # Drive API
  uuid: ^4.4.2
  intl: ^0.19.0
  fl_chart: ^0.70.0            # Chart/grafik
  go_router: ^14.6.2
  freezed: ^2.5.7              # Immutable models
  json_serializable: ^6.8.0

dev_dependencies:
  drift_dev: ^2.21.0
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.1
  freezed_annotation: ^2.4.4
  mockito: ^5.4.4
  flutter_test:
    sdk: flutter
```

---

## Open Questions

> [!IMPORTANT]
> **Q1: Target Platform Prioritas?**
> Android dulu, atau iOS dan Android bersamaan? Ini mempengaruhi konfigurasi Google Sign-In dan background sync.

> [!IMPORTANT]
> **Q2: Multi-user atau Single-user?**
> Apakah satu perangkat bisa dipakai beberapa profil pengguna, atau satu akun Google per device?

> [!NOTE]
> **Q3: Export Laporan?**
> Apakah perlu export ke PDF/Excel di v1, atau cukup tampilan in-app dulu?

> [!NOTE]
> **Q4: Desain UI/Theme?**
> Preferensi warna utama? Modern minimal, atau colorful/playful? Dark mode sebagai default?
