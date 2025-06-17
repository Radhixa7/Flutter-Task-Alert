# 📱 Task Alert – Flutter To-Do App with Smart Notifications

**Task Alert** adalah aplikasi manajemen tugas berbasis Flutter yang memungkinkan pengguna untuk menambahkan, mengelola, dan menerima notifikasi pengingat tugas secara otomatis sebelum deadline. Dirancang dengan UI modern, UX efisien, dan dukungan penyimpanan lokal menggunakan Hive.

---

## 📦 Fitur Utama

✅ Tambah, edit, dan hapus tugas  
✅ Set deadline & prioritas (Low, Medium, High)  
✅ Rekomendasi prioritas otomatis berbasis deskripsi dan deadline  
✅ 🔔 Notifikasi otomatis sebelum deadline (dengan timezone support)  
✅ Indikator visual untuk tugas yang lewat deadline  
✅ Penyimpanan lokal dengan Hive (tanpa koneksi internet)  
✅ Tema gelap & terang (Dark Mode)  
✅ Responsive UI dengan Material 3  
✅ Multi-language (opsional, default: Bahasa Indonesia)

---

## 🛠 Teknologi yang Digunakan

| Teknologi              | Deskripsi                                     |
|------------------------|-----------------------------------------------|
| `Flutter`              | Framework utama                              |
| `Dart`                 | Bahasa pemrograman                           |
| `Provider`             | State management                             |
| `Hive`                 | Local database untuk penyimpanan tugas       |
| `flutter_local_notifications` | Library untuk menjadwalkan notifikasi  |
| `timezone`             | Mendukung penjadwalan notifikasi akurat      |
| `permission_handler`   | Meminta izin notifikasi (Android 13+)        |
| `google_fonts`         | Font modern (Inter)                          |

---

## 🧑‍💻 Cara Menjalankan Proyek Ini

1. **Clone repositori:**

   ```bash
   git clone https://github.com/username/task-alert.git
   cd task-alert
````

2. **Install dependensi:**

   ```bash
   flutter pub get
   ```

3. **Build file Hive:**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Jalankan di emulator/device:**

   ```bash
   flutter run
   ```

> ⚠️ Pastikan Android 13+ memberikan izin notifikasi saat aplikasi pertama kali dibuka.

---

## 🧠 Fitur Selanjutnya (Backlog)

* [ ] Sinkronisasi tugas ke cloud (Firebase)
* [ ] Reminder berulang (daily/weekly)
* [ ] Dashboard visual progress
* [ ] Google Calendar Integration

---

## ✍️ Kontribusi

Pull Request sangat terbuka! Jika kamu memiliki saran, bugfix, atau penambahan fitur, silakan fork dan kirim PR.

---

## ⚖️ Lisensi

Aplikasi ini menggunakan lisensi [MIT License](LICENSE).

---

## 👤 Developer

Dibuat oleh \[Kelomopok5]

```
