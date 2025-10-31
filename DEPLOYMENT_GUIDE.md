# POS Mobile App - Deployment and Testing Guide

## Testing

### Unit Testing

Create test files for models and services:

```dart
// test/models/product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/models/product.dart';

void main() {
  group('Product Model', () {
    test('Product.fromJson creates correct instance', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'price': 50.0,
        'unitOfMeasure': 'pcs',
        'stockQuantity': 100,
        'isWeighable': false,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.price, 50.0);
    });

    test('Product.toJson returns correct map', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        price: 50.0,
        unitOfMeasure: 'pcs',
        stockQuantity: 100,
        isWeighable: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = product.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Product');
      expect(json['price'], 50.0);
    });
  });
}
```

### Widget Testing

```dart
// test/screens/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile_app/screens/home_screen.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/providers/products_provider.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('HomeScreen displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => ProductsProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Welcome to POS System'), findsOneWidget);
    });

    testWidgets('HomeScreen displays action cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => ProductsProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Scan Barcode'), findsOneWidget);
      expect(find.text('Connect Scale'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });
  });
}
```

### Integration Testing

```dart
// test_driver/app.dart
import 'package:flutter/material.dart';
import 'package:pos_mobile_app/main.dart';

void main() {
  runApp(const MyApp());
}
```

```dart
// test_driver/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_mobile_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('POS App Integration Tests', () {
    testWidgets('Complete purchase flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for app to load
      await tester.pumpAndSettle();

      // Navigate to products
      await tester.tap(find.text('Browse Products'));
      await tester.pumpAndSettle();

      // Add product to cart
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // Navigate to cart
      await tester.tap(find.text('Cart'));
      await tester.pumpAndSettle();

      // Proceed to checkout
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Complete purchase
      await tester.tap(find.text('Complete Purchase'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Order created'), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/models/product_test.dart

# Run integration tests
flutter test integration_test/app_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Building for Production

### Android Build

```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Build APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS Build

```bash
# Build for iOS
flutter build ios --release

# Create IPA for TestFlight
flutter build ios --release

# Archive and upload to App Store
# Use Xcode or fastlane
```

### Web Build

```bash
# Build for web
flutter build web --release

# Deploy to hosting service
# Copy build/web/* to your hosting server
```

## Configuration for Production

### Environment Variables

Create `.env.production`:
```
API_BASE_URL=https://api.yourpos.com
API_TIMEOUT=30
ENABLE_LOGGING=false
LHDN_API_KEY=your_production_api_key
LHDN_API_SECRET=your_production_api_secret
```

### App Configuration

Update `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.yourpos.com';
  // ... other config
}
```

## Deployment Steps

### Step 1: Prepare Release Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run analyzer
flutter analyze

# Run tests
flutter test
```

### Step 2: Build Release APK/IPA

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Step 3: Sign and Upload

**Android (Google Play):**
1. Go to Google Play Console
2. Create new release
3. Upload APK/AAB
4. Fill in release notes
5. Submit for review

**iOS (App Store):**
1. Open Xcode
2. Select Product > Archive
3. Upload to App Store Connect
4. Fill in app information
5. Submit for review

### Step 4: Monitor Deployment

- Monitor crash reports
- Check user reviews
- Monitor performance metrics
- Be ready for hotfixes

## Performance Optimization

### Code Optimization

```dart
// Use const constructors
const MyWidget();

// Use const collections
const items = [1, 2, 3];

// Avoid rebuilds with proper state management
Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.itemCount}');
  },
)
```

### Image Optimization

```dart
// Use appropriate image sizes
Image.network(
  'https://example.com/image.jpg',
  cacheHeight: 200,
  cacheWidth: 200,
)

// Use image compression
// Use WebP format when possible
```

### Network Optimization

```dart
// Implement caching
final response = await _dio.get(
  '/api/products',
  options: Options(
    extra: {'cachePolicy': CachePolicy.FORCE_CACHE},
  ),
);

// Batch requests
Future.wait([
  _apiService.getProducts(),
  _apiService.getCustomers(),
  _apiService.getOrders(),
]);
```

## Monitoring and Analytics

### Error Tracking

```dart
import 'package:sentry/sentry.dart';

void main() async {
  await Sentry.init(
    'YOUR_SENTRY_DSN',
    tracesSampleRate: 1.0,
  );
  runApp(const MyApp());
}
```

### Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Log events
await analytics.logEvent(
  name: 'purchase_complete',
  parameters: {
    'amount': 100.0,
    'currency': 'MYR',
  },
);
```

## Troubleshooting Production Issues

### App Crashes

1. Check crash logs in Google Play Console / App Store Connect
2. Review error tracking service (Sentry, Firebase)
3. Reproduce issue locally
4. Fix and deploy hotfix

### Performance Issues

1. Profile app with DevTools
2. Check network requests
3. Optimize heavy operations
4. Implement caching

### API Connection Issues

1. Verify API endpoint is accessible
2. Check API rate limits
3. Implement retry logic
4. Add offline support

## Versioning

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `major.minor.patch+buildNumber`

## Release Checklist

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Performance optimized
- [ ] Security reviewed
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Build tested on real devices
- [ ] Screenshots updated
- [ ] Release notes prepared
- [ ] API endpoint configured
- [ ] Analytics configured
- [ ] Error tracking configured
- [ ] Ready for submission

## Post-Launch

1. **Monitor**: Watch for crashes and errors
2. **Engage**: Respond to user reviews
3. **Iterate**: Plan next features
4. **Maintain**: Regular updates and patches

## Support

For deployment issues, contact the development team or refer to:
- [Flutter Deployment Documentation](https://flutter.dev/docs/deployment)
- [Google Play Console Help](https://support.google.com/googleplay)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

