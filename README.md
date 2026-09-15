# 🏦 Cakue — Catat Keuangan Gue

Aplikasi pencatatan keuangan pribadi enterprise-grade yang mendukung **Offline-First**, **Multi-User**, **Dark Mode dynamic**, dan menyinkronkan data ke **Google Drive** & **MySQL 8.0 Database**.

---

## 🚀 Cara Memulai

### 1. Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.22.0
- Dart ≥ 3.4.0
- Docker & Docker Compose (Opsional untuk opsi kontainerisasi)
- MySQL Server 8.0+ (Opsional jika menggunakan database MySQL terpisah)

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup & Inisialisasi Database (MySQL 8.0)

Aplikasi Cakue menggunakan **MySQL 8.0** sebagai backend database relasional utama. Inisialisasi skema dan data awal (*seed data*) berjalan otomatis melalui file [`init.sql`](file:///Users/macbookpro/Desktop/Cakue/init.sql).

#### Opsi A: Menggunakan Docker Compose (Direkomendasikan)

Jalankan seluruh stack (Web App + MySQL 8.0) dengan satu perintah:

```bash
docker-compose up --build -d
```

Service MySQL akan otomatis mengimpor [`init.sql`](file:///Users/macbookpro/Desktop/Cakue/init.sql) saat container pertama kali dibuat.

#### Opsi B: Manual / Server MySQL Lokal

Jika menguji secara manual di MySQL lokal:

```bash
mysql -u root -p < init.sql
```

---

## 🗄️ Spesifikasi Database MySQL 8.0

Database Cakue dirancang dengan struktur terintegrasi, indeks performa tinggi, dan integritas *referential integrity* (Foreign Keys).

### Kredensial Default (Docker Environment)

| Parameter | Value Default |
| --- | --- |
| **Host** | `localhost` / `cakue-db` (Docker internal) |
| **Port** | `3306` |
| **Database** | `cakue_db` |
| **User** | `cakue_user` |
| **Password** | `cakue_password` |
| **Root Password** | `root_password` |
| **Charset / Collation** | `utf8mb4` / `utf8mb4_unicode_ci` |

### Struktur Tabel Database (8 Tabel Core)

| Tabel | Deskripsi & Responsibilitas | Foreign Keys |
| --- | --- | --- |
| **`currencies`** | Katalog mata uang (IDR, USD, SGD, EUR) & opsi base currency | - |
| **`user_profiles`** | Profil pengguna multi-user (UUID) | - |
| **`accounts`** | Rekening bank, e-wallet, dompet tunai, dan investasi | `currency_code` → `currencies.code`<br>`user_uuid` → `user_profiles.uuid` |
| **`categories`** | Kategori transaksi berjenjang (*parent-child*) | `parent_uuid` → `categories.uuid` |
| **`transactions`** | Pencatatan transaksi (*Income*, *Expense*, *Transfer*) | `account_uuid` → `accounts.uuid`<br>`category_uuid` → `categories.uuid`<br>`currency_code` → `currencies.code` |
| **`monthly_summaries`** | Tabel pre-agregasi untuk dashboard & analitik cepat | `currency_code` → `currencies.code` |
| **`budgets`** | Pengaturan batas anggaran per kategori | `category_uuid` → `categories.uuid` |
| **`sync_logs`** | Log audit riwayat sinkronisasi Google Drive | - |

---

## 🏗️ Arsitektur Aplikasi

Aplikasi dibangun menggunakan prinsip **Clean Architecture + MVVM** (Model-View-ViewModel) dengan **Riverpod** sebagai manajer *state*:

```text
lib/
├── core/           # Theme (Light/Dark Pawli design), Router (GoRouter), Utilities
├── data/           # Data Layer: Repositories, MySQL Client, Drift/Local DAO
├── domain/         # Domain Layer: Entities, Repositories Interfaces, UseCases
├── presentation/   # Presentation Layer: Widgets, Screens, ViewModels (MVVM)
└── di/             # Dependency Injection (Riverpod Providers)
```

---

## 🎨 Design System & Dark Mode

Tampilan UI didasarkan pada palette **Pawli Brand Identity** dengan dukungan penuh untuk **Light Mode** & **Dark Mode** konsisten:

| Warna | Light Mode Hex | Dark Mode Hex | Peranan UI |
| --- | --- | --- | --- |
| **Coral** | `#FD7F65` | `#FF6B4A` | Accent Utama, Tombol Utama, Expense |
| **Sage** | `#8FA87A` | `#769360` | Secondary, Status Positif, Income |
| **Steel Blue** | `#6B87C7` | `#4F6FA8` | Transfer, Kartu Informasi |
| **Forest Dark** | `#3E4F2C` | `#1A2413` | Header, Balance Card Accent |
| **Background** | `#FAF9F6` | `#121214` | Latar Belakang Layar |
| **Card Surface** | `#FFFFFF` | `#1E1E22` | Permukaan Kartu & Container |

Typography: **Plus Jakarta Sans** (Google Fonts).

---

## ⚡ Optimalisasi Query & Performa Analitik

1. **Skema Pre-Agregasi (`monthly_summaries`)**: Query dashboard mengeksekusi data dari `monthly_summaries` (< 5ms) tanpa men-scan jutaan baris di tabel `transactions`.
2. **Indexing Strategis**: Indeks khusus pada `(date DESC)`, `(account_uuid, date DESC)`, dan `(user_uuid, year_month)` menjamin kecepatan query transaksi & filter bulanan.
3. **Reactive Riverpod Providers**: State management hanya melakukan *re-render* pada komponen yang mengalami perubahan data.

---

## ☁️ Google Drive Sync & Conflict Resolution

- Data disinkronkan dalam bentuk format terenkripsi JSON ke folder khusus `appDataFolder`.
- Menggunakan strategi **Last-Write-Wins (LWW)** berbasis timestamp `updated_at` untuk menangani konflik data antar perangkat.
- Status pelacakan sync via kolom `sync_status` (`pending`, `synced`, `conflict`).

---

## 📋 Status Fitur & Roadmap

### v1.1 (Saat ini)

- [x] Migrasi penuh ke skema **MySQL 8.0** & **Docker Compose**
- [x] Perbaikan penuh **Dark Mode** & kontras komponen UI
- [x] Fitur penambahan & pengelolaan Rekening (Bank, E-Wallet, Cash, Credit)
- [x] Multi-user profile switcher
- [x] Pencatatan & filter transaksi berjenjang
- [x] Export laporan ke format Excel

### Roadmap Mendatang

- [ ] Google Drive Cloud Auto-Sync
- [ ] AI Receipt Scanner (Gemini API Integration)
- [ ] Budget Alert & Limit Warning System
- [ ] Live Multi-currency Exchange Rates

---

## 📦 Tech Stack Utama

| Library / Tool | Versi | Peranan |
| --- | --- | --- |
| **MySQL** | `8.0` | Relational Database Backend |
| **Flutter SDK** | `3.22.x` | Cross-platform UI Framework |
| **flutter_riverpod** | `2.6.1` | State Management & Dependency Injection |
| **go_router** | `14.6.2` | Declarative Routing System |
| **fl_chart** | `0.70.0` | Data Visualization & Analytics Charts |
| **excel** | `4.0.6` | Generation Export Laporan Excel |

