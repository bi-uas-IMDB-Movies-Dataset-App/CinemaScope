![Banner](https://capsule-render.vercel.app/api?type=waving&height=260&color=0:0f172a,50:1e3a5f,100:f5c518&text=CinemaScope&fontColor=ffffff&fontSize=52&fontAlignY=38&desc=Flutter%20Web%20%C2%B7%20Supabase%20Auth%20%C2%B7%20PostgreSQL%20%C2%B7%20BI%20Dashboard&descAlignY=58&animation=fadeIn)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Auth%20%2B%20DB-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Status](https://img.shields.io/badge/Status-Live-f5c518?style=for-the-badge)](https://github.com/)

---

### 🌐 Live Demo & Sumber Daya Proyek

| Sumber Daya | Tautan |
|---|---|
| 🗃️ **Dataset Kotor (Kaggle)** | [IMDB Top 1000 Movies & TV Shows](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows?resource=download) |
| 🧹 **Data Bersih (Google Colab)** | [Lihat Notebook Pembersihan Data](https://colab.research.google.com/drive/1Qt-ZTBZjdUjU0tHvRJT6GbTEAFmLCNLK?usp=sharing) |
| 📊 **Slide Presentasi (PPT)** | *(insert link PPT/Canva di sini)* |
| 📄 **Laporan Proyek (PDF)** | *(insert link Google Drive laporan di sini)* |
| 🖼️ **Poster Proyek** | *(insert link Google Drive poster di sini)* |

---

## 📑 Daftar Isi

- [🎯 Ringkasan Proyek](#-ringkasan-proyek)
- [✨ Fitur Utama](#-fitur-utama)
- [🛠️ Stack Teknologi](#️-stack-teknologi)
- [🗂️ Struktur Folder](#️-struktur-folder)
- [🗃️ Skema Database](#️-skema-database)
- [🔀 Alur Data & Pipeline BI](#-alur-data--pipeline-bi)
- [🧩 Arsitektur Komponen](#-arsitektur-komponen)
- [🚀 Quick Start](#-quick-start)
- [🧭 Halaman Aplikasi](#-halaman-aplikasi)
- [🔐 Fitur Keamanan](#-fitur-keamanan)
- [🧪 Testing & Smoke Test](#-testing--smoke-test)
- [📦 Deployment](#-deployment)
- [📊 Sumber Daya Proyek](#-sumber-daya-proyek)
- [👥 Anggota Tim — Invincible 🔥](#-anggota-tim--sidang-berapi)

---

## 🎯 Ringkasan Proyek

**CinemaScope** adalah aplikasi web berbasis **Flutter + Supabase** yang terinspirasi dari IMDb, dikembangkan sebagai implementasi tugas akhir mata kuliah **Business Intelligence (BI)**. Proyek ini mencakup seluruh pipeline BI — mulai dari pengumpulan data mentah, pembersihan, penyimpanan, hingga visualisasi dan pengambilan keputusan berbasis data.

Aplikasi menyediakan dua lapisan utama:

- **Halaman Pengguna (Viewer)** — Dapat diakses setelah login; menampilkan daftar film, pencarian, filter genre, watchlist personal, rating, dan **dashboard analitik gaya BI/OLAP** berisi insight mendalam tentang data film.
- **Panel Admin** — Hanya dapat diakses oleh pengguna berole `admin`; memiliki kemampuan CRUD penuh untuk data film dan manajemen pengguna.

> **Konteks UAS Business Intelligence:** Proyek ini menerapkan siklus BI secara penuh — mengumpulkan data dari Kaggle (IMDB Top 1000), membersihkan data melalui Google Colab, mengimpor ke PostgreSQL via Supabase, lalu mengimplementasikannya ke dalam aplikasi dengan dashboard analitik yang informatif dan actionable.

**Fokus pengembangan:**

- **Pipeline BI end-to-end** — Dari data kotor Kaggle hingga visualisasi siap pakai.
- **Dashboard analitik OLAP** — Insight berdasarkan genre, rating, metascore, dan tren film.
- **Autentikasi & otorisasi berbasis role** — Menggunakan Supabase Auth + Row Level Security (RLS).
- **Watchlist & rating personal** — Pengalaman pengguna yang terpersonalisasi.
- **Admin CRUD** — Pengelolaan konten film dan user oleh administrator.

---

## ✨ Fitur Utama

### 🎬 Halaman Pengguna (Viewer)

**🏠 Beranda / Movies Browsing**

- Menampilkan daftar film dari dataset IMDB Top 1000 yang telah dibersihkan.
- Card film menampilkan poster, judul, tahun rilis, genre, dan rating IMDb.

**🔍 Search & Filter Genre**

- Cari film berdasarkan kata kunci (judul, sutradara, aktor).
- Filter berdasarkan genre untuk mempersempit hasil pencarian.

**📊 Explore — Dashboard Analytics (BI/OLAP Style)**

- Ringkasan metrik utama: total film, rata-rata IMDb rating, distribusi genre.
- Visualisasi chart interaktif menggunakan `fl_chart`: bar chart genre, scatter plot rating vs metascore, tren tahun rilis.
- Insight untuk mendukung pengambilan keputusan berbasis data.

**📋 Watchlist Personal**

- Pengguna dapat menambahkan dan menghapus film ke/dari watchlist pribadi.
- Data watchlist tersimpan per akun di PostgreSQL (Supabase).

**⭐ Viewer Rating & Metascore**

- Pengguna memberikan rating personal untuk setiap film yang sudah ditonton.
- Metascore disajikan sebagai indikator agregat penilaian kritis.

---

### 🛠️ Panel Admin

**🔑 Autentikasi & Otorisasi**

- Login berbasis **Supabase Auth** (email + password).
- Role-based access control menggunakan tabel `user_roles` dan **Supabase Row Level Security (RLS)**.
- Operasi admin hanya bisa dilakukan oleh pengguna berole `admin`.

**🎬 Manajemen Film (Admin CRUD)**

- **Tambah** film baru — judul, genre, tahun, durasi, rating IMDb, metascore, sutradara, aktor, sinopsis, poster.
- **Edit** data film yang sudah ada.
- **Hapus** film dari database.

**👤 Manajemen User**

- Lihat daftar pengguna terdaftar.
- Kelola role pengguna (`viewer` / `admin`).
- Nonaktifkan akun jika diperlukan.

---

## 🛠️ Stack Teknologi

| Kategori | Teknologi |
|---|---|
| **Frontend Framework** | Flutter 3.x (Dart) — target: Web |
| **State Management** | Provider |
| **Chart / Visualisasi** | fl_chart |
| **Autentikasi** | Supabase Auth (email + password) |
| **Database** | PostgreSQL 15+ (via Supabase) |
| **Backend / BaaS** | Supabase (REST API + Realtime) |
| **Keamanan Data** | Row Level Security (RLS) Supabase |
| **Sumber Dataset** | [Kaggle – IMDB Top 1000](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows) |
| **Pipeline Pembersihan Data** | Python (Google Colab + Pandas) |
| **Environment Config** | `.env` via `flutter_dotenv` |

---

## 🗂️ Struktur Folder

<details>
<summary><strong>📂 Klik untuk memperluas struktur folder lengkap</strong></summary>

```
cinemascope/
|
+-- lib/
|   |
|   +-- core/
|   |   +-- supabase_client.dart        -> Inisialisasi Supabase client
|   |   +-- router.dart                 -> Routing aplikasi (go_router / Navigator)
|   |   +-- constants.dart              -> Konstanta global
|   |
|   +-- features/
|   |   +-- auth/
|   |   |   +-- login_screen.dart       -> Halaman login
|   |   |   +-- register_screen.dart    -> Halaman registrasi
|   |   |
|   |   +-- movies/
|   |   |   +-- movies_screen.dart      -> Daftar film (browsing)
|   |   |   +-- movie_detail_screen.dart -> Detail film
|   |   |   +-- search_screen.dart      -> Halaman pencarian
|   |   |
|   |   +-- dashboard/
|   |   |   +-- dashboard_screen.dart   -> Dashboard analytics (BI/OLAP)
|   |   |   +-- charts/                 -> Widget chart fl_chart
|   |   |
|   |   +-- watchlist/
|   |   |   +-- watchlist_screen.dart   -> Halaman watchlist personal
|   |   |
|   |   +-- admin/
|   |       +-- admin_movies_screen.dart -> CRUD film (admin)
|   |       +-- admin_users_screen.dart  -> Manajemen user (admin)
|   |
|   +-- models/
|   |   +-- movie.dart                  -> Model data film
|   |   +-- user_profile.dart           -> Model profil pengguna
|   |   +-- watchlist_item.dart         -> Model item watchlist
|   |   +-- rating.dart                 -> Model rating film
|   |
|   +-- providers/
|   |   +-- auth_provider.dart          -> State autentikasi & role
|   |   +-- movies_provider.dart        -> State daftar film & filter
|   |   +-- watchlist_provider.dart     -> State watchlist personal
|   |   +-- rating_provider.dart        -> State rating pengguna
|   |   +-- dashboard_provider.dart     -> State data analytics dashboard
|   |
|   +-- widgets/
|   |   +-- movie_card.dart             -> Card komponen film
|   |   +-- genre_chip.dart             -> Chip filter genre
|   |   +-- rating_stars.dart           -> Widget bintang rating
|   |   +-- stat_card.dart              -> Card statistik dashboard
|   |
|   +-- theme/
|   |   +-- app_theme.dart              -> Tema warna & tipografi
|   |
|   +-- main.dart                       -> Entry point aplikasi
|
+-- assets/
|   +-- .env                            -> Konfigurasi environment (gitignored)
|   +-- images/                         -> Aset gambar statis
|
+-- supabase/
|   +-- cinemascope_supabase.sql        -> Skema tabel, RLS policy, seed data
|
+-- data/
|   +-- imdb_raw.csv                    -> Dataset mentah dari Kaggle
|   +-- imdb_clean.csv                  -> Dataset setelah pembersihan (Colab)
|
+-- pubspec.yaml                        -> Dependensi Flutter
+-- .gitignore
+-- README.md
```

</details>

---

## 🗃️ Skema Database

Database `cinemascope` di Supabase PostgreSQL terdiri dari **5 tabel** utama.

### Tabel `movies`

Menyimpan data film hasil import dataset IMDB yang telah dibersihkan.

```sql
CREATE TABLE movies (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title           VARCHAR(300) NOT NULL,
    year            INT,
    certificate     VARCHAR(20),
    runtime_minutes INT,
    genre           VARCHAR(200),
    imdb_rating     DECIMAL(3,1),
    meta_score      INT,
    director        VARCHAR(200),
    star1           VARCHAR(150),
    star2           VARCHAR(150),
    star3           VARCHAR(150),
    star4           VARCHAR(150),
    votes           BIGINT,
    gross           BIGINT,
    overview        TEXT,
    poster_url      VARCHAR(500),
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabel `user_profiles`

Menyimpan profil pengguna yang terhubung ke tabel `auth.users` Supabase.

```sql
CREATE TABLE user_profiles (
    id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username    VARCHAR(100),
    full_name   VARCHAR(200),
    avatar_url  VARCHAR(500),
    role        VARCHAR(20) DEFAULT 'viewer' CHECK (role IN ('viewer','admin')),
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabel `watchlists`

Menyimpan daftar film yang ditambahkan pengguna ke watchlist pribadi.

```sql
CREATE TABLE watchlists (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    movie_id    UUID REFERENCES movies(id) ON DELETE CASCADE,
    added_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, movie_id)
);
```

### Tabel `ratings`

Menyimpan rating personal pengguna untuk setiap film.

```sql
CREATE TABLE ratings (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    movie_id    UUID REFERENCES movies(id) ON DELETE CASCADE,
    score       DECIMAL(3,1) CHECK (score >= 1 AND score <= 10),
    review      TEXT,
    rated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, movie_id)
);
```

### Tabel `genres` *(lookup)*

Tabel referensi genre untuk keperluan filter dan analitik.

```sql
CREATE TABLE genres (
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) UNIQUE NOT NULL
);
```

---

## 🔀 Alur Data & Pipeline BI

Berikut adalah alur lengkap dari data mentah hingga visualisasi di aplikasi:

```
1. COLLECT
   Kaggle Dataset (imdb_raw.csv)
   └─> IMDB Top 1000 Movies & TV Shows
       https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows

2. CLEAN & TRANSFORM
   Google Colab (Python + Pandas)
   └─> Notebook: https://colab.research.google.com/drive/1Qt-ZTBZjdUjU0tHvRJT6GbTEAFmLCNLK
       - Hapus duplikat & nilai null
       - Normalisasi kolom (genre, runtime, gross)
       - Standarisasi tipe data
       - Ekspor ke imdb_clean.csv

3. LOAD
   Import ke Supabase PostgreSQL
   └─> Tabel: movies (via SQL COPY atau Supabase dashboard import)

4. SERVE
   Supabase REST API
   └─> Flutter app mengkonsumsi data via Supabase Dart client

5. VISUALIZE & ANALYZE
   Dashboard Analytics (fl_chart)
   └─> Distribusi genre, top rated films, tren tahun,
       korelasi rating vs metascore, analisis gross revenue
```

---

## 🧩 Arsitektur Komponen

```
User / Admin
     |
     v
Flutter Web App (Browser)
     |
     +---> Provider (State Management)
     |           |
     |           +---> Supabase Dart Client
     |                       |
     |                       +---> Supabase Auth      <- Login / Register / Role check
     |                       |
     |                       +---> PostgreSQL (REST)  <- Query tabel movies, watchlist, dll
     |                       |
     |                       +---> Row Level Security <- Proteksi data per user/role
     |
     +---> fl_chart           <- Render visualisasi dashboard
     |
     +---> Provider State     <- movies, watchlist, rating, auth, dashboard
```

### Komponen Utama

| File/Folder | Peran |
|---|---|
| `core/supabase_client.dart` | Inisialisasi dan ekspor Supabase client singleton |
| `providers/auth_provider.dart` | Mengelola state login, logout, dan role pengguna |
| `providers/movies_provider.dart` | Fetch, filter, dan search daftar film |
| `providers/dashboard_provider.dart` | Aggregasi data untuk chart dan metrik BI |
| `features/dashboard/` | Tampilan dan logika dashboard analitik |
| `supabase/cinemascope_supabase.sql` | DDL skema tabel + RLS policy + seed genre |

---

## 🚀 Quick Start

<details>
<summary><strong>⚙️ Klik untuk instruksi instalasi lengkap</strong></summary>

### Prasyarat

- Flutter SDK 3.x terinstal
- Dart SDK 3.x
- Akun Supabase (gratis) dan project aktif
- Python 3.x + Pandas (untuk pipeline pembersihan data, opsional)

### 1. Clone Repository

```bash
git clone https://github.com/[username]/cinemascope.git
cd cinemascope
```

### 2. Setup Database Supabase

Masuk ke dashboard Supabase project → SQL Editor, lalu jalankan:

```bash
# Jalankan file skema dan policy
supabase/cinemascope_supabase.sql
```

Kemudian import data bersih ke tabel `movies`:

- Gunakan fitur **Table Editor → Import CSV** di Supabase dashboard.
- Upload file `data/imdb_clean.csv`.

### 3. Konfigurasi Environment

Salin template dan isi dengan kredensial Supabase project:

```bash
cp assets/.env.example assets/.env
```

```env
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> Temukan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di **Settings → API** pada dashboard Supabase.

### 4. Install Dependencies & Jalankan

```bash
flutter pub get
flutter run -d chrome
```

### 5. Akses di Browser

```
Halaman utama  : http://localhost:XXXX/
Admin panel    : Login menggunakan akun dengan role = 'admin'

Akun default (setelah seed):
  Email    : admin@cinemascope.dev
  Password : Admin123!
```

> Segera **ganti password default** setelah pertama kali login!

</details>

---

## 🧭 Halaman Aplikasi

| Halaman | Route | Data Utama | Fungsi |
|---|---|---|---|
| **Login** | `/login` | Form auth | Autentikasi pengguna via Supabase |
| **Register** | `/register` | Form registrasi | Daftar akun baru (role: viewer) |
| **Movies** | `/movies` | Daftar film + filter | Browsing & pencarian film |
| **Detail Film** | `/movies/:id` | Info lengkap film | Lihat detail, beri rating, tambah watchlist |
| **Dashboard / Explore** | `/dashboard` | Chart & metrik | Analitik BI — distribusi genre, tren rating |
| **Watchlist** | `/watchlist` | Film tersimpan | Daftar film yang ingin ditonton |
| **Admin — Film** | `/admin/movies` | CRUD data film | Kelola konten film (khusus admin) |
| **Admin — Users** | `/admin/users` | Daftar user + role | Kelola pengguna (khusus admin) |

---

## 🔐 Fitur Keamanan

### Supabase Row Level Security (RLS)

Setiap tabel dilindungi RLS policy yang memastikan:
- Pengguna hanya dapat membaca/mengubah data milik sendiri (watchlist, rating).
- Operasi INSERT/UPDATE/DELETE pada tabel `movies` hanya bisa dilakukan oleh role `admin`.
- Tabel `user_profiles` hanya bisa diakses oleh pemilik akun atau admin.

### Role-Based Access Control

Role pengguna (`viewer` / `admin`) disimpan di tabel `user_profiles` dan dibaca oleh `AuthProvider`. Halaman dan operasi admin diperiksa sebelum dirender — pengguna tanpa role `admin` diarahkan kembali ke halaman utama.

### Environment Variable Protection

Supabase URL dan Anon Key disimpan di `assets/.env` yang masuk ke dalam `.gitignore` — tidak pernah di-commit ke repository. Anon Key Supabase bersifat publik secara desain, namun akses data tetap aman berkat RLS.

### Validasi Input

Setiap form (login, register, CRUD admin) divalidasi di sisi client sebelum dikirim ke Supabase untuk mencegah data tidak valid masuk ke database.

---

## 🧪 Testing & Smoke Test

### Syntax & Analisis Statis

```bash
# Periksa error dan warning
flutter analyze

# Format kode
dart format lib/
```

### Smoke Test Endpoint & Fitur

```
# Auth
[ ] Login berhasil dengan kredensial valid
[ ] Login gagal menampilkan pesan error yang sesuai
[ ] Register akun baru berhasil

# Halaman Pengguna
[ ] Daftar film tampil setelah login
[ ] Search mengembalikan hasil yang relevan
[ ] Filter genre mengubah daftar film
[ ] Detail film menampilkan data lengkap
[ ] Tambah film ke watchlist → tersimpan
[ ] Hapus film dari watchlist → terhapus
[ ] Submit rating → tersimpan dan terbaca

# Dashboard Analytics
[ ] Chart genre tampil dengan data yang benar
[ ] Metrik ringkasan (total film, avg rating) akurat
[ ] Visualisasi responsif di berbagai ukuran layar

# Admin Panel
[ ] Halaman admin tidak bisa diakses oleh role viewer
[ ] Tambah film baru → muncul di daftar film
[ ] Edit film → perubahan tersimpan
[ ] Hapus film → film hilang dari daftar
[ ] Manajemen user berfungsi

# Error Handling
[ ] Token expired → redirect ke login
[ ] Koneksi Supabase gagal → tampil pesan error yang sesuai
```

---

## 📦 Deployment

### Development (Flutter Web)

```bash
flutter run -d chrome --web-port 8080
```

### Build Produksi

```bash
flutter build web --release
```

Output berada di `build/web/` — dapat di-deploy ke:
- **Firebase Hosting** (`firebase deploy`)
- **Netlify** (drag & drop folder `build/web/`)
- **Vercel** (dengan konfigurasi `vercel.json`)
- **cPanel / VPS** (upload isi `build/web/` ke `public_html/`)

### Checklist Produksi

- [ ] Pastikan `.env` tidak ikut ter-build ke output publik
- [ ] Aktifkan RLS pada **semua** tabel di Supabase
- [ ] Ganti password akun admin default
- [ ] Aktifkan HTTPS (SSL/TLS)
- [ ] Review Supabase Auth settings (email confirmation, rate limit)
- [ ] Set `DB_AUTO_SEED=false` untuk environment produksi

---

## 📊 Sumber Daya Proyek

### 🗃️ Dataset & Pipeline BI

| Tahap | Keterangan | Tautan |
|---|---|---|
| **Data Kotor** | IMDB Top 1000 Movies & TV Shows — Kaggle | [Buka di Kaggle](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows?resource=download) |
| **Data Bersih** | Notebook pembersihan data — Google Colab (Python + Pandas) | [Buka di Colab](https://colab.research.google.com/drive/1Qt-ZTBZjdUjU0tHvRJT6GbTEAFmLCNLK?usp=sharing) |

### 📊 Slide Presentasi (PPT)

Slide deck untuk presentasi proyek — berisi latar belakang, pipeline BI, arsitektur aplikasi, screenshot demo, dan insight analitik:

***(insert link PPT/Canva di sini)***

---

### 📄 Laporan Proyek (PDF)

Dokumen laporan lengkap — latar belakang, analisis kebutuhan, desain sistem, pipeline BI, implementasi, pengujian, dan kesimpulan:

***(insert link Google Drive laporan di sini)***

---

### 🖼️ Poster Proyek

Poster visual yang merangkum proyek CinemaScope secara ringkas dan informatif:

***(insert link Google Drive poster di sini)***

---

## 👥 Anggota Tim — Invincible 🔥

| Nama | NIM | Role |
|---|---|---|
| Sayid Rafi A'thaya | 2409116036 | Project Manager 💡 |
| Mochammad Rezky Ramadhan | 2409116029 | Backend / Database ⚙️ |
| Adella Putri | 2409116006 | Frontend / UI 🎨 |
| Dhita Olivia Ramadhayanti Kusuma | 2409116040 | Documentation / Report 🧾 |

---

<div align="center">

![Footer](https://capsule-render.vercel.app/api?type=waving&height=120&color=0:f5c518,100:0f172a&section=footer)

**CinemaScope** &nbsp;·&nbsp; Dibangun oleh Kelompok ?  
*UAS Business Intelligence — Implementasi BI End-to-End*

[![Kaggle](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=flat-square&logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows)
[![Colab](https://img.shields.io/badge/Data_Cleaning-Colab-F9AB00?style=flat-square&logo=googlecolab&logoColor=white)](https://colab.research.google.com/drive/1Qt-ZTBZjdUjU0tHvRJT6GbTEAFmLCNLK?usp=sharing)

</div>
