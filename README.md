# POS Mobile App

Flutter mobile application for Point of Sale (POS) system.

## 🚀 Features

- **Product Browsing** - Browse and search products
- **Shopping Cart** - Add/remove items, adjust quantities
- **Checkout** - Multiple payment methods (cash, card, credit)
- **Customer Management** - Track customer credit accounts
- **Weighing Scale Integration** - Bluetooth connectivity for weighable items
- **Offline Support** - Basic offline capabilities
- **Real-time Sync** - Sync with backend API

## 📱 Screenshots

Coming soon...

## 🛠️ Tech Stack

- **Framework:** Flutter 3.35.6
- **Language:** Dart 3.9.2
- **State Management:** Provider
- **HTTP Client:** Dio
- **Bluetooth:** flutter_blue_plus
- **Storage:** Hive

## 📋 Prerequisites

- Flutter SDK 3.35.6 or higher
- Dart 3.9.2 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, Mac only)

## 🔧 Installation

### 1. Clone Repository

```bash
git clone https://github.com/matjaki91-cmd/pos-mobile-app.git
cd pos-mobile-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API URL

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### 4. Run App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

## 📦 Build APK

### Debug Build

```bash
flutter build apk --debug
```

### Release Build

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📖 Documentation

- [Deployment Guide](PANDUAN_DEPLOYMENT_MVP.md)
- [User Guide](PANDUAN_PENGGUNA_POS.md)
- [Git Setup Guide](PANDUAN_GIT_SETUP.md)
- [APK Build Guide](CARA_BUILD_APK.md)
- [Testing Guide](TESTING_GUIDE.md)

## 🏗️ Project Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── services/        # Business logic & API
├── providers/       # State management
├── screens/         # UI screens
└── main.dart        # Entry point
```

## 🔐 Environment Variables

Create `.env` file (not committed to git):

```
API_BASE_URL=https://your-backend-url.com
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is proprietary and confidential.

## 📞 Support

For support, email support@yourcompany.com

## 🎯 Roadmap

- [x] Basic POS flow
- [x] Product management
- [x] Customer credit system
- [ ] Weighing scale integration (testing)
- [ ] LHDN e-invoicing
- [ ] Receipt printing
- [ ] Barcode scanning
- [ ] Staff management
- [ ] E-commerce integration (Shopee, TikTok)

## 👥 Authors

- **Development** - Manus AI
- **Project Owner** - matjaki91-cmd

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors and testers

---

**Version:** 1.0.0  
**Last Updated:** October 2024
