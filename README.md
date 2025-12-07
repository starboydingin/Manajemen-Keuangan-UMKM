# Flutter PTI – Platform Manajemen Keuangan UMKM

Platform terpadu yang memadukan **Flutter** (front-end) dan **Express + MySQL** (back-end) untuk membantu pelaku UMKM mengelola transaksi, memantau arus kas, dan menghasilkan laporan otomatis dengan gaya antarmuka retro neon ala tactical UI.

## ✨ Sorotan Fitur

- **Auth lengkap**: registrasi, login, logout dengan JWT + password hashing Bcrypt.
- **Dashboard finansial**: stat card, feed transaksi, dan CTA cepat untuk menambah pemasukan/pengeluaran.
- **Manajemen profil**: nama pengguna & nama usaha tersimpan di server dan sinkron antar sesi.
- **Laporan otomatis**: periode bulanan, mingguan, dan custom dengan friendly error/empty state.
- **Penyimpanan daring**: endpoint referensi file (`cloud_storage_refs`) untuk integrasi cloud storage eksternal.
- **Tema retro futurism**: warna neon, card gradien, dan layout yang responsif baik di mobile maupun desktop web.

## 🧱 Stack Utama

| Layer | Teknologi |
| --- | --- |
| Frontend | Flutter 3.9+, Provider, SharedPreferences, flutter_secure_storage |
| Backend | Node.js 18+, Express, JWT, Bcrypt |
| Database | MySQL / MariaDB |
| Tools | VS Code, Postman, Git, PowerShell |

## 👥 Tim Pengembang (Kelompok 24)

| NPM | Nama | Role | GitHub |
| --- | --- | --- | --- |
| 2315061080 | Galang Pambudi Utama | Ketua | [@hino89](https://github.com/hino89) |
| 2315061013 | Alexander Lawrensius | Anggota | [@Alexander-cloud29](https://github.com/Alexander-cloud29) |
| 2315061074 | Adwika Farsha Ardhan | Anggota | [@starboydingin](https://github.com/starboydingin) |
| 2315061119 | Rendy Antono | Anggota | [@rendyant](https://github.com/rendyant) |

## 📖 Deskripsi Singkat

Flutter PTI dibuat untuk memudahkan UMKM menghitung arus kas tanpa berpindah perangkat. Backend menyediakan REST API yang aman, sedangkan aplikasi Flutter menyajikan pengalaman pengguna yang modern dan konsisten, baik di Android, iOS, maupun web.

## 🧩 Arsitektur

```
Flutter App (Provider State)  <-->  API Gateway (Express)  <-->  MySQL
           |                              |                      |
      Secure Storage                Auth Middleware           Relasional Schema
```

- **Frontend** berkomunikasi via HTTP, menyimpan token di `flutter_secure_storage`, dan menyinkronkan profil ke SharedPreferences.
- **Backend** memverifikasi JWT, mengelola revoked token, serta menyediakan resource transaksi, laporan, kategori, dan penyimpanan daring.

## 🚀 Instalasi & Menjalankan

### 1. Persiapan Database

1. Jalankan MySQL, buat database baru (mis. `flutter_pti`).
2. Eksekusi `database/schema.sql` untuk membuat tabel `users`, `accounts`, `transactions`, `balances`, `financial_reports`, `cloud_storage_refs`, `revoked_tokens`, dan lainnya.

### 2. Backend (Express)

```powershell
cd backend
cp .env.example .env   # sesuaikan nilai env
npm install
npm run dev            # server di http://localhost:4000
```

Contoh `.env`:

```
PORT=4000
APP_JWT_SECRET=super_secret_key
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=flutter_pti
STORAGE_BASE_URL=https://storage.example.com
```

### 3. Frontend (Flutter)

```powershell
cd flutter_pti
flutter pub get
flutter run --dart-define API_BASE_URL=http://localhost:4000/api/v1
```

> Jalankan `flutter run -d chrome` jika ingin melihat tema retro neon di browser.

## 🔌 Ringkasan Endpoint (`/api/v1`)

| Endpoint | Method | Deskripsi |
| --- | --- | --- |
| `/auth/register` | POST | Registrasi user + akun usaha default |
| `/auth/login` | POST | Masuk dan dapatkan JWT |
| `/auth/logout` | POST | Revoke token (disimpan hashed) |
| `/profile` | GET/PUT | Ambil atau update nama user & usaha |
| `/accounts/:accountId/transactions` | GET/POST | Baca atau tambah transaksi |
| `/accounts/:accountId/balance` | GET | Snapshot saldo (total income, expense, current balance) |
| `/accounts/:accountId/reports` | GET | Laporan otomatis (monthly/weekly/custom) |
| `/storage` | POST | Simpan referensi file daring (report/backup) |

Contoh request registrasi:

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "fullName": "Adwika",
  "email": "adwika@example.com",
  "password": "rahasia123",
  "businessName": "Adwika Mart"
}
```

Semua endpoint (kecuali `/auth/*`) membutuhkan header `Authorization: Bearer <token>`.

## 🗂 Struktur Folder

```
Flutter-PTI/
├─ backend/              # Express REST API + MySQL schema
│  ├─ src/
│  │  ├─ controllers/
│  │  ├─ middleware/
│  │  ├─ repositories/
│  │  └─ services/
│  └─ database/schema.sql
├─ flutter_pti/          # Flutter app
│  ├─ lib/
│  │  ├─ src/data/
│  │  ├─ src/presentation/
│  │  └─ src/state/
│  └─ pubspec.yaml
└─ README.md             # File ini
```

## 🔧 Roadmap Pengembangan Lanjutan

- Refresh token + rotasi kunci JWT.
- Notifikasi push untuk pengingat pencatatan harian.
- Integrasi penyimpanan cloud sebenarnya (S3/Firebase Storage) di endpoint `/storage`.
- Pengujian otomatis (Jest untuk backend, Flutter test/golden test untuk UI).
- CI/CD sederhana di GitHub Actions (lint + test + build).

## ☕ Saran Penggunaan

Gaya antarmuka retro neon cocok dipadukan dengan branding UMKM modern (kedai kopi, toko retail kreatif). Cocok ditayangkan di tablet kasir, sehingga operator bisa langsung memasukkan transaksi sambil melihat rasio laba rugi secara real time.
