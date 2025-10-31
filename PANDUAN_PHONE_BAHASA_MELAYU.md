# Panduan Preview App di Mobile Phone - Langkah demi Langkah (Bahasa Melayu)

Anda nak test app di phone sebenar? Bagus! Ini lebih mudah dan lebih cepat dari emulator.

---

## LANGKAH 1: Siapkan Phone Anda (Android)

### Kalau anda guna **Android Phone**:

1. **Buka Settings (Tetapan)**
   - Scroll down cari "About Phone" atau "Tentang Telefon"
   - Tap "About Phone"

2. **Cari "Build Number"**
   - Scroll down dalam About Phone
   - Cari "Build Number"

3. **Tap "Build Number" 7 Kali**
   - Tap cepat-cepat 7 kali
   - Anda akan nampak message: "You are now a developer"
   - Tahniah! Developer mode aktif!

4. **Enable USB Debugging**
   - Balik ke Settings
   - Cari "Developer Options" atau "Pilihan Pembangun"
   - Tap untuk buka
   - Cari "USB Debugging"
   - Toggle ON (warna biru)

5. **Trust Computer (Penting!)**
   - Nanti anda akan connect phone ke computer
   - Phone akan tanya "Trust this computer?"
   - Tap "Allow" atau "Yes"

---

## LANGKAH 2: Siapkan Phone Anda (iPhone)

### Kalau anda guna **iPhone**:

1. **Buka Settings**
2. **Tap "Developer"** (jika ada)
3. **Enable Developer Mode**
4. **Buka Xcode** (di Mac)
5. **Connect iPhone dengan USB cable**

(iPhone lebih complicated, tapi saya akan ajar step by step nanti kalau anda perlukan)

---

## LANGKAH 3: Connect Phone ke Komputer

### Guna USB Cable:

1. **Ambil USB cable** (sama cable yang anda guna untuk charge phone)
2. **Connect phone ke komputer**
3. **Phone akan tanya "Trust this computer?"**
   - Tap "Allow" atau "Trust"
   - Jangan lupa tap "Always Allow"

---

## LANGKAH 4: Check Phone Dah Connect

Buka Terminal/Command Prompt dan type:

```bash
flutter devices
```

Tekan Enter.

**Anda akan nampak:**

```
2 connected devices:

SM-G960F (mobile)     • • • android-arm64  • Android 10 (API 29)
```

Kalau anda nampak phone anda dalam list, bermakna **phone dah connect betul!** ✅

---

## LANGKAH 5: Navigate ke Folder App

```bash
cd /home/ubuntu/pos_mobile_app
```

Tekan Enter.

---

## LANGKAH 6: Download Dependencies (Jika Belum)

```bash
flutter pub get
```

Tekan Enter. Tunggu sampai siap.

---

## LANGKAH 7: Run App di Phone

Sekarang jalankan app di phone:

```bash
flutter run
```

Tekan Enter.

**Apa yang akan jadi:**

1. Terminal akan show: "Building..."
2. Phone akan nampak app sedang install
3. Tunggu 2-5 minit
4. **App akan muncul di phone anda!** 🎉

---

## LANGKAH 8: Test App di Phone

Sekarang anda boleh main dengan app:

### Test 1: Tekan Buttons
- Tekan "Browse Products"
- Tekan "Customers"
- Tekan "Orders"

### Test 2: Add to Cart
1. Tekan "Browse Products"
2. Tekan "+" button untuk add item
3. Lihat item ditambah

### Test 3: Checkout
1. Tekan icon shopping cart atas
2. Tekan "Checkout"
3. Pilih payment method
4. Tekan "Complete Purchase"

---

## LANGKAH 9: Stop App

Kalau nak stop:

1. Balik ke Terminal
2. Tekan `Ctrl + C`
3. App akan stop

---

## Tips Berguna

### Tip 1: Hot Reload (Update Cepat)

Kalau anda edit code dan nak lihat changes:

1. Edit file (contoh: ubah warna button)
2. Save file
3. Di Terminal, tekan `r`
4. App akan update dalam 1-2 second!

Ini sangat berguna untuk development!

### Tip 2: Full Restart

Kalau hot reload x jalan:

1. Di Terminal, tekan `R` (capital R)
2. App akan restart

### Tip 3: View Logs

Kalau ada error, anda boleh lihat di Terminal:

```
I/flutter (12345): Error message akan nampak sini
W/flutter (12345): Warning message
```

---

## Masalah Biasa & Cara Selesaikan

### Masalah 1: "No devices found"

**Jawapan:**
1. Check phone dah connect dengan USB cable
2. Check USB Debugging dah ON
3. Check phone dah tap "Allow" untuk trust computer
4. Try disconnect dan connect semula

**Kalau masih x jalan:**
```bash
flutter devices
```
Lihat apa error message.

### Masalah 2: "Device not authorized"

**Jawapan:**
1. Disconnect phone
2. Di phone, buka Settings → Developer Options
3. Cari "Revoke USB Debugging Authorizations"
4. Tap untuk reset
5. Connect phone semula
6. Tap "Allow" untuk trust computer

### Masalah 3: App crash atau error

**Jawapan:**
1. Stop app (Ctrl + C)
2. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Masalah 4: "Gradle build failed"

**Jawapan:**
```bash
flutter clean
flutter pub get
flutter run
```

### Masalah 5: Phone screen x update

**Jawapan:**
1. Tekan `r` untuk hot reload
2. Kalau x jalan, tekan `R` untuk full restart

---

## Cara Disconnect Phone

Kalau anda dah selesai testing:

1. **Tekan Ctrl + C** di Terminal untuk stop app
2. **Disconnect USB cable** dari phone
3. **Selesai!**

---

## Perbezaan Emulator vs Physical Phone

| Benda | Emulator | Physical Phone |
|------|----------|----------------|
| Speed | Slow (first time 10 min) | Fast (2-5 min) |
| Realism | Tidak sama dengan real phone | Exactly like real phone |
| Bluetooth | Sukar test | Boleh test dengan real scale |
| Battery | N/A | Boleh test battery usage |
| Recommended | Untuk development | Untuk testing |

**Saya recommend:** Guna physical phone untuk testing! Lebih cepat dan lebih realistic.

---

## Langkah Seterusnya

Selepas app jalan di phone:

1. **Test semua buttons** - Make sure semua jalan
2. **Test dengan API** - Connect ke backend server
3. **Test Bluetooth** - Kalau ada weighing scale
4. **Test Payment** - Test cash, card, credit
5. **Test Error Handling** - Disconnect internet dan test

---

## Perintah Penting

```bash
# Navigate ke folder
cd /home/ubuntu/pos_mobile_app

# Check devices
flutter devices

# Download dependencies
flutter pub get

# Run app di phone
flutter run

# Stop app
Ctrl + C

# Hot reload (tekan r)
r

# Full restart (tekan R)
R

# Clean build
flutter clean
```

---

## Troubleshooting Checklist

Kalau ada masalah, check satu-satu:

- [ ] USB cable connected?
- [ ] USB Debugging ON?
- [ ] Phone trusted computer?
- [ ] `flutter devices` show phone?
- [ ] Folder app correct? (`/home/ubuntu/pos_mobile_app`)
- [ ] Dependencies downloaded? (`flutter pub get`)
- [ ] Internet connected?

---

## Perlu Bantuan?

Kalau stuck, message saya dengan:

1. **Error message** yang keluar di Terminal
2. **Phone model** (contoh: Samsung Galaxy A12)
3. **Android version** (Settings → About → Android version)

Saya akan help anda selesaikan!

---

## Selamat Mencuba! 🚀

Anda sekarang boleh test app di phone sebenar! 

Enjoy! 😊

---

## Quick Reference

**Untuk Android Phone:**
```bash
# 1. Enable USB Debugging (Settings → Developer Options)
# 2. Connect dengan USB cable
# 3. Trust computer di phone
# 4. Run:
flutter devices          # Check phone connected
flutter run              # Run app di phone
```

**Untuk iPhone:**
```bash
# 1. Connect dengan USB cable
# 2. Open Xcode
# 3. Run:
flutter devices          # Check phone connected
flutter run              # Run app di phone
```

**Kalau ada error:**
```bash
flutter clean
flutter pub get
flutter run
```

**Untuk update code tanpa restart:**
```bash
# Tekan 'r' di Terminal untuk hot reload
# Tekan 'R' di Terminal untuk full restart
```

