# Panduan Setup Git & GitHub - Bahasa Melayu

Saya dah setup Git repository untuk project ini! Sekarang anda perlu push ke GitHub supaya boleh sync dengan computer anda.

---

## ✅ Apa Yang Dah Siap

- [x] Git repository initialized
- [x] All files committed
- [x] Ready to push ke GitHub

---

## 🚀 Langkah untuk Push ke GitHub

### **Step 1: Buat GitHub Account** (Kalau Belum Ada)

1. Pergi ke https://github.com
2. Click "Sign up"
3. Ikut arahan untuk buat account
4. Verify email anda

### **Step 2: Buat New Repository di GitHub**

1. Login ke GitHub
2. Click "+" button atas kanan
3. Click "New repository"
4. **Repository name:** `pos-mobile-app`
5. **Description:** "POS Mobile App with Flutter"
6. **Public** atau **Private** (pilih mana suka)
7. **JANGAN** check "Initialize this repository with a README"
8. Click "Create repository"

### **Step 3: Copy Repository URL**

Selepas create repository, anda akan nampak page dengan commands. Copy URL yang nampak macam ni:

```
https://github.com/YOUR_USERNAME/pos-mobile-app.git
```

### **Step 4: Push Code ke GitHub**

Saya akan berikan anda commands untuk run. **Ganti `YOUR_USERNAME` dengan GitHub username anda!**

```bash
cd /home/ubuntu/pos_mobile_app

# Add GitHub repository sebagai remote
git remote add origin https://github.com/YOUR_USERNAME/pos-mobile-app.git

# Push code ke GitHub
git branch -M main
git push -u origin main
```

**Kalau diminta username & password:**
- Username: GitHub username anda
- Password: **Personal Access Token** (bukan password biasa!)

### **Step 5: Buat Personal Access Token** (Kalau Perlu)

Kalau GitHub minta password dan reject password biasa anda:

1. Pergi ke https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. **Note:** "POS Mobile App"
4. **Expiration:** 90 days (atau No expiration)
5. **Select scopes:** Check ✅ `repo` (semua)
6. Click "Generate token"
7. **COPY TOKEN!** (Simpan kat tempat selamat, x boleh lihat lagi!)
8. Guna token ni sebagai password bila push

---

## 💻 Clone ke Computer Anda

Selepas push ke GitHub, anda boleh clone ke computer:

```bash
# Navigate ke folder anda
cd C:\Projects\

# Clone repository
git clone https://github.com/YOUR_USERNAME/pos-mobile-app.git

# Masuk ke folder
cd pos-mobile-app

# Download dependencies
flutter pub get

# Run app!
flutter run
```

---

## 🔄 Workflow Update (Selepas Setup)

### Kalau Saya Edit Di Cloud:

```bash
# Di cloud (saya buat):
cd /home/ubuntu/pos_mobile_app
git add .
git commit -m "Update home screen"
git push
```

### Kalau Anda Nak Update Di Computer:

```bash
# Di computer anda:
cd pos-mobile-app
git pull
flutter pub get  # Kalau ada dependency changes
flutter run
```

**Selesai!** Perubahan auto sync!

---

## 📋 Commands Yang Penting

### Di Cloud (Saya Run):

```bash
# Commit changes
git add .
git commit -m "Describe what changed"
git push

# Check status
git status

# View history
git log --oneline
```

### Di Computer Anda:

```bash
# Get latest changes
git pull

# Check what changed
git status

# View history
git log --oneline

# Undo changes (kalau ada masalah)
git reset --hard HEAD
```

---

## 🎯 Quick Reference

| Action | Command |
|--------|---------|
| Get latest code | `git pull` |
| Save changes | `git add . && git commit -m "message"` |
| Upload changes | `git push` |
| Check status | `git status` |
| View history | `git log` |
| Undo changes | `git reset --hard HEAD` |

---

## ✅ Checklist Setup

- [ ] Buat GitHub account
- [ ] Buat new repository `pos-mobile-app`
- [ ] Copy repository URL
- [ ] Run commands di cloud untuk push
- [ ] Clone ke computer anda
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Test app jalan!

---

## 🔐 Security Tips

1. **JANGAN share Personal Access Token** dengan orang lain
2. **Simpan token** di tempat selamat (password manager)
3. **Set expiration** untuk token (90 days recommended)
4. **Revoke token** kalau x guna lagi

---

## 💡 Tips Berguna

### Tip 1: Git Aliases

Buat commands lebih pendek:

```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
```

Lepas tu boleh guna:
```bash
git st    # instead of git status
git ci -m "message"  # instead of git commit -m "message"
```

### Tip 2: .gitignore

File `.gitignore` dah ada untuk ignore:
- Build files
- Dependencies (node_modules, etc.)
- IDE files
- Temporary files

### Tip 3: Commit Messages

Buat commit messages yang clear:

✅ **Good:**
```bash
git commit -m "Add weighing scale integration"
git commit -m "Fix cart total calculation bug"
git commit -m "Update home screen UI"
```

❌ **Bad:**
```bash
git commit -m "update"
git commit -m "fix"
git commit -m "changes"
```

---

## 🚨 Troubleshooting

### Masalah 1: "Permission denied"

**Jawapan:**
- Check GitHub username & token betul
- Pastikan token ada `repo` permissions

### Masalah 2: "Repository not found"

**Jawapan:**
- Check repository URL betul
- Pastikan repository dah create di GitHub

### Masalah 3: "Merge conflict"

**Jawapan:**
```bash
git pull --rebase
# Resolve conflicts manually
git add .
git rebase --continue
git push
```

### Masalah 4: "Failed to push"

**Jawapan:**
```bash
git pull --rebase
git push
```

---

## 📞 Perlu Bantuan?

Kalau stuck, message saya dengan:

1. **Error message** yang keluar
2. **Command** yang anda run
3. **Screenshot** (kalau boleh)

Saya akan help selesaikan!

---

## 🎉 Selesai!

Selepas setup Git:

✅ Code ada di GitHub (backup!)
✅ Boleh sync antara cloud & computer
✅ Boleh track semua changes
✅ Boleh rollback kalau ada masalah
✅ Boleh collaborate dengan team

---

## Next Steps

1. **Push ke GitHub** (ikut Step 1-4 atas)
2. **Clone ke computer** anda
3. **Test app** jalan di computer
4. **Edit & commit** changes
5. **Push & pull** untuk sync

**Selamat coding!** 🚀

---

## Repository Info

**Project:** POS Mobile App
**Location (Cloud):** `/home/ubuntu/pos_mobile_app`
**GitHub:** `https://github.com/YOUR_USERNAME/pos-mobile-app` (ganti YOUR_USERNAME)
**Branch:** `main`
**Initial Commit:** ✅ Done

---

**Ready untuk push ke GitHub!** 

Ikut langkah-langkah di atas untuk complete setup! 😊

