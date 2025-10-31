# POS System Mobile App

A comprehensive Flutter-based Point of Sale (POS) system mobile application for Android and iOS, designed to work seamlessly with the backend API.

## Features

### Core Features (MVP)
- **Product Management**: Browse and search products from the backend database
- **Shopping Cart**: Add, remove, and manage items in the shopping cart
- **Checkout**: Complete purchase transactions with multiple payment methods
- **Customer Management**: Support for customer selection and credit accounts
- **Weighable Items**: Special handling for products that require weight measurement
- **Payment Methods**: Cash, Card, and Credit Account payment options
- **Order Creation**: Automatic order creation with items and customer information

### Advanced Features (Coming Soon)
- **Barcode/QR Code Scanning**: Scan products directly into cart
- **Weighing Scale Integration**: Aclas O2SX and Imin DW1 support
- **LHDN Integration**: E-invoicing submission and receipt generation
- **Staff Management**: Check-in/check-out with fingerprint or camera
- **Inventory Management**: Stock in/out tracking with supplier management
- **Online Payment**: Integration with payment gateways
- **E-commerce Sync**: Shopee and TikTok Shop order synchronization

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── config/
│   └── api_config.dart      # API configuration and endpoints
├── models/
│   ├── product.dart         # Product data model
│   ├── customer.dart        # Customer data model
│   ├── order.dart           # Order and OrderItem models
│   └── cart_item.dart       # Shopping cart item model
├── services/
│   ├── api_service.dart     # Backend API communication
│   └── bluetooth_service.dart # Weighing scale Bluetooth integration
├── providers/
│   ├── cart_provider.dart   # Cart state management
│   └── products_provider.dart # Products state management
├── screens/
│   ├── home_screen.dart     # Home/dashboard screen
│   ├── products_screen.dart # Products browsing screen
│   ├── cart_screen.dart     # Shopping cart screen
│   └── checkout_screen.dart # Checkout and payment screen
└── utils/                   # Utility functions and helpers
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure API endpoint in `lib/config/api_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-backend-url.com';
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## API Integration

The app communicates with the backend API using tRPC endpoints. All API calls are handled by the `ApiService` class.

### Available Endpoints
- Products: `/api/trpc/product.list`, `/api/trpc/product.get`
- Customers: `/api/trpc/customer.list`, `/api/trpc/customer.get`, `/api/trpc/customer.create`
- Orders: `/api/trpc/order.list`, `/api/trpc/order.create`
- Inventory: `/api/trpc/inventory.recordInbound`
- Credit: `/api/trpc/credit.recordTransaction`

## State Management

Uses Provider package for state management:
- **CartProvider**: Manages shopping cart state
- **ProductsProvider**: Manages products and search functionality

## Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Dependencies

- `flutter`: Flutter SDK
- `provider`: State management
- `dio`: HTTP client
- `flutter_bluetooth_serial`: Bluetooth communication
- `barcode_scan2`: Barcode scanning
- `qr_flutter`: QR code generation
- `shared_preferences`: Local storage
- `hive`: Local database
- `pdf`: PDF generation
- `printing`: Print functionality
- `google_fonts`: Font management
- `intl`: Internationalization
- `connectivity_plus`: Network connectivity
- `flutter_local_notifications`: Local notifications

## Troubleshooting

- **API Connection Issues**: Verify backend server is running and API URL is correct
- **Bluetooth Issues**: Enable Bluetooth and ensure scale is paired
- **Build Issues**: Run `flutter clean` and `flutter pub get`

## Future Enhancements

- Offline mode with local sync
- Advanced barcode scanning
- Weighing scale real-time display
- LHDN e-invoicing
- Staff management
- E-commerce integration
- Advanced analytics
- Multi-language support
- Dark mode

## License

Proprietary and Confidential
