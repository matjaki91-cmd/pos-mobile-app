# Panduan Preview App POS - Langkah demi Langkah (Bahasa Melayu)

Saya akan ajar anda step by step macam mana nak lihat app yang saya dah buat. Ini sangat mudah!

## Apa yang Anda Perlukan

Sebelum kita mulai, pastikan anda ada:

1. **Komputer** (Windows, Mac, atau Linux)
2. **Internet connection**
3. **Android emulator** ATAU **iPhone simulator** ATAU **physical device** (telefon Android/iPhone)

Jangan risau kalau anda x ada emulator lagi. Saya akan ajar anda cara install.

---

## LANGKAH 1: Install Flutter (Jika Belum Ada)

Flutter adalah tools yang kita gunakan untuk buat dan run app.

### Untuk Windows:

1. Pergi ke https://flutter.dev/docs/get-started/install/windows
2. Download Flutter SDK
3. Extract file yang download ke folder (contoh: `C:\flutter`)
4. Buka Command Prompt dan run:
   ```
   flutter --version
   ```
   Jika keluar version number, bermakna Flutter dah install betul.

### Untuk Mac:

```bash
# Buka Terminal dan run:
brew install flutter
flutter --version
```

### Untuk Linux:

```bash
# Buka Terminal dan run:
sudo apt-get install flutter
flutter --version
```

---

## LANGKAH 2: Setup Android Emulator (Pilihan A - Paling Mudah)

Kalau anda ada Android Studio, ini paling mudah:

1. **Buka Android Studio**
2. **Click "More Actions" → "Virtual Device Manager"**
3. **Click "Create device"**
4. **Pilih "Pixel 4" atau "Pixel 5"**
5. **Click "Next"**
6. **Pilih "Android 12" atau lebih baru**
7. **Click "Next" → "Finish"**
8. **Click tombol play (▶️) untuk start emulator**

Tunggu sampai emulator siap (akan nampak home screen Android).

---

## LANGKAH 3: Buka Terminal/Command Prompt

### Windows:
- Tekan `Win + R`
- Type `cmd`
- Press Enter

### Mac/Linux:
- Buka "Terminal" app

---

## LANGKAH 4: Navigate ke Folder App

Copy-paste command ini ke terminal anda:

```bash
cd /home/ubuntu/pos_mobile_app
```

Tekan Enter.

---

## LANGKAH 5: Download Dependencies (Bahan-bahan)

App kita perlu banyak "bahan" untuk jalan. Kita download dulu:

```bash
flutter pub get
```

Tekan Enter. Tunggu sampai siap (boleh ambil 2-3 minit).

Anda akan nampak text yang banyak. Jangan risau, itu normal.

---

## LANGKAH 6: Run App di Emulator

Sekarang kita jalankan app!

```bash
flutter run
```

Tekan Enter.

**Apa yang akan jadi:**
1. Emulator akan load app
2. Anda akan nampak text "Building..." 
3. Tunggu sampai siap (boleh ambil 5-10 minit untuk first time)
4. App akan appear di emulator screen!

---

## LANGKAH 7: Lihat App Jalan

Selepas app load, anda akan nampak:

```
┌─────────────────────────────────────┐
│  Welcome to POS System              │
│                                     │
│  [Browse Products]                  │
│  [Customers]                        │
│  [Orders]                           │
│  [Connect Scale]                    │
│                                     │
└─────────────────────────────────────┘
```

**Tahniah!** App dah jalan! 🎉

---

## LANGKAH 8: Test App - Click Buttons

Sekarang anda boleh click buttons di emulator:

### Test 1: Browse Products
1. Click button "Browse Products"
2. Anda akan nampak list of products
3. Click back untuk balik ke home

### Test 2: Add to Cart
1. Click "Browse Products"
2. Click "+" button untuk add item
3. Anda akan nampak item ditambah ke cart
4. Click "Cart" icon atas untuk lihat cart

### Test 3: Checkout
1. Dari cart, click "Checkout"
2. Anda akan nampak payment options
3. Pilih "Cash" atau "Credit"
4. Click "Complete Purchase"

---

## LANGKAH 9: Stop App

Kalau anda nak stop app:

1. Balik ke Terminal/Command Prompt
2. Tekan `Ctrl + C`
3. App akan stop

---

## Masalah Biasa & Cara Selesaikan

### Masalah 1: "flutter command not found"

**Jawapan:**
- Anda belum install Flutter dengan betul
- Pergi balik ke LANGKAH 1 dan install Flutter

### Masalah 2: "No devices found"

**Jawapan:**
- Emulator belum start
- Buka Android Studio dan start emulator (LANGKAH 2)

### Masalah 3: App crash atau error

**Jawapan:**
1. Stop app (Ctrl + C)
2. Run command ini:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Masalah 4: Emulator sangat slow

**Jawapan:**
- Emulator memang slow di first time
- Tunggu 5-10 minit
- Atau gunakan physical device (telefon sebenar)

---

## Cara Guna Physical Device (Telefon Sebenar)

Kalau anda ada Android phone:

1. **Enable USB Debugging:**
   - Buka Settings → About Phone
   - Tap "Build Number" 7 kali
   - Balik ke Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect telefon ke komputer dengan USB cable**

3. **Di Terminal, check device:**
   ```bash
   flutter devices
   ```

4. **Run app:**
   ```bash
   flutter run
   ```

---

## Apa yang Boleh Anda Test

### ✅ Benda yang Dah Siap:

1. **Home Screen** - Main page dengan buttons
2. **Products Screen** - List of products
3. **Cart** - Shopping cart
4. **Checkout** - Payment screen
5. **Customer Selection** - Pilih customer untuk credit payment

### ⏳ Benda yang Belum Siap (Akan Buat Nanti):

1. Barcode scanning
2. Weighing scale connection
3. Receipt printing
4. LHDN e-invoicing
5. Shopee/TikTok integration

---

## Tips Berguna

### Tip 1: Hot Reload (Cepat Update)

Kalau anda edit code, anda x perlu stop dan run semula:

1. Edit file (contoh: `lib/screens/home_screen.dart`)
2. Save file
3. Di Terminal, tekan `r`
4. App akan update dalam 1 second!

### Tip 2: Full Restart

Kalau hot reload x jalan:

1. Di Terminal, tekan `R` (capital R)
2. App akan restart

### Tip 3: View Logs

Kalau ada error, anda boleh lihat di Terminal:

```
I/flutter (12345): Error message akan nampak sini
```

---

## Langkah Seterusnya

Selepas anda test app dan semua jalan:

1. **Customize app** - Tukar warna, nama, logo
2. **Connect ke backend** - Update API URL
3. **Add more features** - Barcode scanning, weighing scale, etc.
4. **Build release** - Siap untuk upload ke Google Play / App Store

---

## Perlu Bantuan?

Kalau ada masalah:

1. **Check error message** - Baca apa yang keluar di Terminal
2. **Try flutter clean** - Bersihkan build cache
3. **Restart emulator** - Close dan buka semula
4. **Restart komputer** - Kadang kala kena restart

---

## Ringkasan Perintah Penting

```bash
# Navigate ke folder app
cd /home/ubuntu/pos_mobile_app

# Download dependencies
flutter pub get

# Run app
flutter run

# Clean build
flutter clean

# Check devices
flutter devices

# Stop app
Ctrl + C

# Hot reload (tekan r)
r

# Full restart (tekan R)
R
```

---

## Selamat Mencuba! 🚀

Anda sekarang dah tahu cara preview app! Kalau ada soalan, tanya saya.

Enjoy testing! 😊

