# Flutter PTI Monorepo

Flutter front-end + Express REST API untuk aplikasi pencatatan keuangan UKM.

`flutter_pti/` → aplikasi Flutter (Provider, SharedPreferences + flutter_secure_storage, theming retro neon).
`backend/` → Node.js (Express) + MySQL dengan autentikasi JWT, transaksi, laporan otomatis, penyimpanan file metadata.

## 1. Persiapan Lingkungan

| Komponen | Versi Minimum |
| --- | --- |
| Flutter SDK | 3.9 (stable) |
| Node.js | 18.x |
| MySQL | 8.x |

## 2. Backend Setup

1. Buat database baru lalu jalankan `database/schema.sql` (akan membuat tabel users, accounts, balances, transactions, cloud_storage_refs, revoked_tokens, dll.).
2. Salin `.env.example` → `.env`, isi kredensial:

  ```env
  PORT=4000
  APP_JWT_SECRET=ganti_dengan_secret_random
  DB_HOST=localhost
  DB_PORT=3306
  DB_USER=root
  DB_PASSWORD=your_password
  DB_NAME=flutter_pti
  STORAGE_BASE_URL=https://storage.example.com
  ```

3. Install dependency & jalankan server:

  ```powershell
  cd backend
  npm install
  npm run dev
  ```

Server berjalan di `http://localhost:4000/api/v1` dengan endpoint kesehatan `/health`.

### Endpoint Highlight

| Endpoint | Method | Catatan |
| --- | --- | --- |
| `/auth/register` | POST | Registrasi + akun usaha default |
| `/auth/login` | POST | Login → JWT 12 jam |
| `/auth/logout` | POST | Revoke token (disimpan hashed di `revoked_tokens`) |
| `/profile` | GET/PUT | Ambil & edit nama user + bisnis |
| `/accounts/:accountId/transactions` | GET/POST | List/Tambah transaksi income/expense |
| `/accounts/:accountId/balance` | GET | Snapshot saldo (total income/expense, balance) |
| `/accounts/:accountId/reports` | GET | Laporan bulanan/mingguan/custom |

Semua endpoint (kecuali `/auth/*`) butuh header `Authorization: Bearer <token>`.

## 3. Flutter App Setup

1. Install dependency:

  ```powershell
  cd flutter_pti
  flutter pub get
  ```

2. Jalankan aplikasi, pastikan backend sudah hidup:

  ```powershell
  flutter run --dart-define API_BASE_URL=http://localhost:4000/api/v1
  ```

### Fitur Flutter

- Form login/registrasi terhubung ke backend (Provider `AuthNotifier`).
- Token & account ID disimpan aman via `flutter_secure_storage`, metadata profil via SharedPreferences.
- Layar profil dapat edit nama lengkap & nama usaha; sinkron ke server dan persist saat logout/refresh.
- Laporan otomatis dengan error banner ramah dan state kosong jika belum ada transaksi.
- Tema neon gelap + komponen custom (stat card, hero profile, dsb.).

## 4. Troubleshooting

- **`fatal: refusing to merge unrelated histories`** → gunakan `git merge <branch> --allow-unrelated-histories` lalu selesaikan konflik seperti README ini.
- **API tidak bisa diakses** → cek `.env`, pastikan MySQL hidup dan `npm run dev` berjalan tanpa error.
- **Flutter tidak bisa login** → pastikan menjalankan aplikasi dengan `--dart-define API_BASE_URL=...` dan backend memakai host/port yang sama.

## 5. Rencana Lanjutan

- Implementasi refresh token & rate limiting.
- Tambah unit/integration test (Jest untuk backend, Flutter test untuk UI/state).
- Integrasi penyimpanan cloud sungguhan lewat endpoint `/storage`.
