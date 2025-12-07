# Flutter PTI Backend

Express + MySQL REST API yang memenuhi kebutuhan fungsional aplikasi pencatatan keuangan:

- **Login & Registrasi** dengan password hashing + JWT.
- **Pencatatan transaksi** pemasukan/pengeluaran per tanggal dan kategori.
- **Manajemen saldo** otomatis (total pemasukan, pengeluaran, dan saldo terkini).
- **Laporan keuangan otomatis** per periode (bulanan, mingguan, custom).
- **Penyimpanan data daring** dengan menyimpan referensi file pada tabel `cloud_storage_refs` (contoh untuk integrasi cloud storage).

## 1. Persiapan Database

1. Buat database MySQL baru (mis. `flutter_pti`).
2. Jalankan skrip `database/schema.sql` untuk membuat seluruh tabel.
3. Isi `.env` berdasarkan `.env.example`:

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

> Gunakan `APP_JWT_SECRET` yang kuat dan berbeda antara environment dev/prod.

## 2. Menjalankan Backend

```powershell
cd E:\Adwika\AdwikaPerkuliahan\PTI\Flutter-PTI\backend
npm install        # sudah dijalankan sekali, ulang jika perlu
npm run dev        # nodemon
```

Server default di `http://localhost:4000`. Endpoint kesehatan tersedia di `/health`.

## 3. Endpoint Utama (`/api/v1`)

| Endpoint | Method | Deskripsi |
| --- | --- | --- |
| `/auth/register` | POST | Registrasi user baru dan buat akun usaha default |
| `/auth/login` | POST | Login dan dapatkan JWT |
| `/accounts/:accountId/transactions` | POST | Tambah transaksi income/expense |
| `/accounts/:accountId/transactions` | GET | List transaksi (filter tanggal/kategori) |
| `/accounts/:accountId/balance` | GET | Dapatkan saldo terkini |
| `/accounts/:accountId/reports` | GET | Laporan otomatis (bulanan/mingguan/custom) |
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

Seluruh endpoint selain `/auth/*` memerlukan header `Authorization: Bearer <token>` dari hasil login.

## 4. Integrasi dengan Flutter

1. Jalankan backend (`npm run dev`).
2. Jalankan database MySQL (lokal atau Docker/XAMPP).
3. Jalankan Flutter app di terminal lain:
   ```powershell
   cd E:\Adwika\AdwikaPerkuliahan\PTI\Flutter-PTI\flutter_pti
   flutter run --dart-define API_BASE_URL=http://localhost:4000/api/v1
   ```
4. Di sisi Flutter, gunakan `API_BASE_URL` untuk memanggil endpoint di atas.

## 5. Pengembangan Lanjutan

- Tambahkan middleware rate limiting atau refresh token jika diperlukan.
- Integrasikan layanan penyimpanan (S3, Firebase Storage) dan simpan metadata-nya lewat endpoint `/storage`.
- Tambahkan unit test (mis. dengan Jest) untuk service layer.
