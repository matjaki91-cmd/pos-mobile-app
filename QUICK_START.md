# POS Mobile App - Quick Start Guide

## Project Overview

This is a complete Flutter-based Point of Sale (POS) system mobile application designed for both Android and iOS platforms. The app connects to a backend API to manage products, customers, orders, and inventory.

## What's Included

### ✅ Completed Features

1. **Project Structure**
   - Clean architecture with separation of concerns
   - Models, services, providers, and screens organized properly
   - Configuration management

2. **Core Screens**
   - Home/Dashboard screen with quick actions
   - Products browsing and search
   - Shopping cart management
   - Checkout and payment processing

3. **State Management**
   - Provider pattern for cart management
   - Products provider with search functionality
   - Reactive UI updates

4. **API Integration**
   - Complete API service with Dio HTTP client
   - Support for products, customers, orders, and inventory
   - Error handling and logging

5. **Weighing Scale Integration**
   - Bluetooth service for scale connectivity
   - Support for Aclas O2SX and Imin DW1 scales
   - Weight data parsing and validation

6. **Payment Methods**
   - Cash payment
   - Card payment (integration ready)
   - Credit account payment with balance tracking

7. **Documentation**
   - Comprehensive README
   - Weighing scale integration guide
   - Credit and payment implementation guide
   - Receipt generation and LHDN integration guide
   - Deployment and testing guide

## Project Structure

```
pos_mobile_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── api_config.dart         # API configuration
│   ├── models/
│   │   ├── product.dart            # Product model
│   │   ├── customer.dart           # Customer model
│   │   ├── order.dart              # Order and OrderItem models
│   │   └── cart_item.dart          # Cart item model
│   ├── services/
│   │   ├── api_service.dart        # Backend API communication
│   │   └── bluetooth_service.dart  # Weighing scale integration
│   ├── providers/
│   │   ├── cart_provider.dart      # Cart state management
│   │   └── products_provider.dart  # Products state management
│   └── screens/
│       ├── home_screen.dart        # Home/dashboard
│       ├── products_screen.dart    # Products browsing
│       ├── cart_screen.dart        # Shopping cart
│       └── checkout_screen.dart    # Checkout and payment
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/                           # Unit and widget tests
├── integration_test/               # Integration tests
├── pubspec.yaml                    # Dependencies
├── README.md                       # Main documentation
├── QUICK_START.md                  # This file
├── WEIGHING_SCALE_INTEGRATION.md   # Scale integration guide
├── CREDIT_PAYMENT_GUIDE.md         # Credit payment guide
├── RECEIPT_LHDN_GUIDE.md           # Receipt and LHDN guide
└── DEPLOYMENT_GUIDE.md             # Deployment guide
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)
- A running POS backend API server

### Installation

1. **Navigate to project directory**
   ```bash
   cd /home/ubuntu/pos_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Edit `lib/config/api_config.dart`
   - Update `baseUrl` to your backend API URL:
   ```dart
   static const String baseUrl = 'https://your-backend-url.com';
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For web (development)
   flutter run -d chrome
   ```

## Key Features

### 1. Product Management
- Browse all products from backend
- Search products by name, barcode, or SKU
- View product details and pricing
- Support for weighable items

### 2. Shopping Cart
- Add/remove items
- Update quantities
- Special handling for weighable items
- Real-time total calculation

### 3. Checkout
- Multiple payment methods (cash, card, credit)
- Customer selection for credit purchases
- Order creation with automatic balance updates
- Order confirmation

### 4. Weighing Scale Integration
- Bluetooth connectivity to scales
- Support for Aclas O2SX and Imin DW1
- Real-time weight reading
- Weight validation

### 5. Customer Credit System
- Create and manage customer accounts
- Track credit balances
- Record credit purchases and payments
- View transaction history

## API Endpoints

The app communicates with these backend endpoints:

```
Products:
- GET /api/trpc/product.list
- GET /api/trpc/product.get

Customers:
- GET /api/trpc/customer.list
- GET /api/trpc/customer.get
- POST /api/trpc/customer.create

Orders:
- GET /api/trpc/order.list
- POST /api/trpc/order.create

Inventory:
- POST /api/trpc/inventory.recordInbound

Credit:
- POST /api/trpc/credit.recordTransaction
```

## Configuration

### API Configuration

Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend-url.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Bluetooth Configuration

For weighing scale integration, ensure Bluetooth permissions are configured in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

## Development

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run linter
dart analyze
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/models/product_test.dart

# Run with coverage
flutter test --coverage
```

### Hot Reload

During development, use hot reload for faster iteration:
```bash
# Press 'r' in terminal to hot reload
# Press 'R' to hot restart
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release
```

### Web

```bash
# Build for web
flutter build web --release
```

## Dependencies

Key packages used:

| Package | Purpose |
|---------|---------|
| provider | State management |
| dio | HTTP client |
| flutter_bluetooth_serial | Bluetooth communication |
| barcode_scan2 | Barcode scanning |
| qr_flutter | QR code generation |
| shared_preferences | Local storage |
| hive | Local database |
| pdf | PDF generation |
| printing | Print functionality |
| google_fonts | Font management |
| intl | Internationalization |

## Troubleshooting

### API Connection Issues
- Verify backend server is running
- Check API URL in `api_config.dart`
- Ensure device can reach the server

### Bluetooth Issues
- Enable Bluetooth on device
- Ensure scale is paired
- Check Bluetooth permissions

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Next Steps

1. **Configure Backend URL**: Update API endpoint in `api_config.dart`
2. **Test API Connection**: Verify app can connect to backend
3. **Configure Weighing Scales**: Set up Bluetooth connectivity
4. **Customize Branding**: Update app name, logo, and colors
5. **Add LHDN Credentials**: Configure for e-invoicing (optional)
6. **Build and Test**: Create release builds for testing
7. **Deploy**: Submit to Google Play and App Store

## Documentation

Refer to these guides for detailed information:

- **README.md** - Complete project documentation
- **WEIGHING_SCALE_INTEGRATION.md** - Scale integration details
- **CREDIT_PAYMENT_GUIDE.md** - Credit system implementation
- **RECEIPT_LHDN_GUIDE.md** - Receipt and LHDN integration
- **DEPLOYMENT_GUIDE.md** - Testing and deployment

## Support

For issues or questions:
1. Check the relevant documentation
2. Review error messages and logs
3. Check Flutter documentation
4. Contact the development team

## Backend API

This app requires a running POS backend API. Ensure the backend is deployed and accessible before using the mobile app.

**Backend Features:**
- Product catalog management
- Customer management
- Order processing
- Inventory tracking
- Credit transaction recording
- LHDN e-invoicing (coming soon)
- E-commerce integration (coming soon)

## Version

- **App Version**: 1.0.0
- **Flutter Version**: 3.35.6
- **Dart Version**: 3.9.2

## License

Proprietary and Confidential

---

**Ready to start?** Follow the Installation steps above to get the app running!

