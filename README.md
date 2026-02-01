# 🎮 Game Wiki App

Aplikasi **wiki game berbasis Flutter & Firebase** yang memungkinkan pemain melihat informasi item dan halaman informasi lain (seperti biome, NPC, dll) secara **realtime**.  
Dirancang agar pemain tetap bisa menemukan barang meskipun lupa nama itemnya, cukup ingat **tooltip atau deskripsinya**.

---

## ✨ Fitur Utama

- 🔍 **Smart Search**  
  Cari berdasarkan **nama, tooltip, atau deskripsi**
- 📦 **Item Pages**  
  Mendukung Buy Price & Sell Price
- 📚 **Info Pages**  
  Halaman informatif tanpa harga (Biome, NPC, dll)
- 🔥 **Realtime Firebase Firestore**
- 🧩 Struktur data scalable (Auto-ID)

---

## 🧱 Struktur Database

<img src="readme%20assets/Struktur%20database%20akun.png" width="600">
<img src="readme%20assets/Struktur%20database%20info%20pages.png" width="600">
<img src="readme%20assets/Struktur%20database%20items.png" width="600">

**Collection utama:**
- `items` → data item game (dengan harga)
- `info_pages` → halaman informasi (tanpa harga)

---

## 📄 Contoh Halaman

### 📦 Items
- Name
- Tooltip
- Description
- Buy Price
- Sell Price

### 📚 Info Pages
- Name
- Tooltip
- Description

---

## 🎥 Demo Aplikasi

> Klik link di bawah untuk melihat demo aplikasi:

[▶️ Lihat Demo Aplikasi](readme%20assets/Demo%20Aplikasi%20Game%20Wiki.mp4)


---

## 🛠️ Tech Stack

- **Flutter** (UI & Logic)
- **Firebase Firestore** (Realtime Database)
- **Material Design**
- **Dart**

---

## 🎯 Tujuan Project

Project ini dibuat untuk:
- Tugas besar UAS Pemrograman Mobile 2
- Membantu pemain mengakses informasi game dengan cepat
- Menjadi dasar wiki game yang **mudah dikembangkan**
- Mendukung penambahan data dalam jumlah besar di masa depan


---

## 📌 Catatan

Semua data disimpan menggunakan **Auto-ID Firestore** untuk menjaga performa dan skalabilitas saat data semakin besar.

---

## 🙌 Penutup

Terima kasih sudah melihat tugas besar UAS aku ini!  
