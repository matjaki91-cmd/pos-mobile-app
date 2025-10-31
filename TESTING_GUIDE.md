# POS Mobile App - Testing Guide

This guide covers all aspects of testing the POS mobile app, from local development to production deployment.

## Table of Contents

1. [Setup for Testing](#setup-for-testing)
2. [Unit Testing](#unit-testing)
3. [Widget Testing](#widget-testing)
4. [Integration Testing](#integration-testing)
5. [Manual Testing](#manual-testing)
6. [Testing Checklist](#testing-checklist)

## Setup for Testing

### Prerequisites

```bash
# Ensure Flutter is installed and up to date
flutter --version

# Get all dependencies
cd /home/ubuntu/pos_mobile_app
flutter pub get

# Run analyzer to check for issues
flutter analyze
```

### Create Test Directory Structure

```bash
# Create test directories if they don't exist
mkdir -p test/models
mkdir -p test/services
mkdir -p test/providers
mkdir -p test/screens
mkdir -p integration_test
```

## Unit Testing

Unit tests verify individual functions and classes work correctly.

### 1. Test Product Model

Create `test/models/product_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/models/product.dart';

void main() {
  group('Product Model Tests', () {
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
      expect(product.stockQuantity, 100);
      expect(product.isWeighable, false);
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

    test('Product equality works correctly', () {
      final product1 = Product(
        id: '1',
        name: 'Product',
        price: 50.0,
        unitOfMeasure: 'pcs',
        stockQuantity: 100,
        isWeighable: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product2 = Product(
        id: '1',
        name: 'Product',
        price: 50.0,
        unitOfMeasure: 'pcs',
        stockQuantity: 100,
        isWeighable: false,
        createdAt: product1.createdAt,
        updatedAt: product1.updatedAt,
      );

      expect(product1, product2);
    });
  });
}
```

### 2. Test Cart Provider

Create `test/providers/cart_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/models/product.dart';
import 'package:pos_mobile_app/models/cart_item.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('Initial cart is empty', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.total, 0.0);
    });

    test('Add item to cart', () {
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

      cartProvider.addItem(product, 2, null);

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[0].quantity, 2);
    });

    test('Remove item from cart', () {
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

      cartProvider.addItem(product, 2, null);
      cartProvider.removeItem('1');

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
    });

    test('Update item quantity', () {
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

      cartProvider.addItem(product, 2, null);
      cartProvider.updateQuantity('1', 5);

      expect(cartProvider.items[0].quantity, 5);
    });

    test('Calculate total correctly', () {
      final product1 = Product(
        id: '1',
        name: 'Product 1',
        price: 50.0,
        unitOfMeasure: 'pcs',
        stockQuantity: 100,
        isWeighable: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final product2 = Product(
        id: '2',
        name: 'Product 2',
        price: 75.0,
        unitOfMeasure: 'pcs',
        stockQuantity: 100,
        isWeighable: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      cartProvider.addItem(product1, 2, null);  // 100
      cartProvider.addItem(product2, 1, null);  // 75
      // Total should be 175

      expect(cartProvider.total, 175.0);
    });

    test('Clear cart', () {
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

      cartProvider.addItem(product, 2, null);
      cartProvider.clear();

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.total, 0.0);
    });
  });
}
```

### 3. Test Bluetooth Service

Create `test/services/bluetooth_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile_app/services/bluetooth_service.dart';

void main() {
  group('BluetoothService Tests', () {
    test('Parse Aclas weight correctly', () {
      final weight = BluetoothService.parseAclasWeight('1234.56\r\n');
      expect(weight, 1234.56);
    });

    test('Parse Aclas weight with extra characters', () {
      final weight = BluetoothService.parseAclasWeight('W:1234.56kg\r\n');
      expect(weight, 1234.56);
    });

    test('Parse Imin weight correctly', () {
      final weight = BluetoothService.parseIminWeight('WT:1234.56\r\n');
      expect(weight, 1234.56);
    });

    test('Parse Imin weight with decimals', () {
      final weight = BluetoothService.parseIminWeight('WT:1234.5\r\n');
      expect(weight, 1234.5);
    });

    test('Handle invalid weight data', () {
      final weight = BluetoothService.parseAclasWeight('INVALID');
      expect(weight, isNull);
    });

    test('Handle empty weight data', () {
      final weight = BluetoothService.parseAclasWeight('');
      expect(weight, isNull);
    });
  });
}
```

### Running Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/models/product_test.dart

# Run tests with verbose output
flutter test --verbose

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Widget Testing

Widget tests verify that UI components render and behave correctly.

### 1. Test Home Screen

Create `test/screens/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile_app/screens/home_screen.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/providers/products_provider.dart';

void main() {
  group('HomeScreen Widget Tests', () {
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

      expect(find.text('Browse Products'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });

    testWidgets('HomeScreen navigation works', (WidgetTester tester) async {
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

      // Tap on Browse Products button
      await tester.tap(find.text('Browse Products'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
```

### 2. Test Cart Screen

Create `test/screens/cart_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile_app/screens/cart_screen.dart';
import 'package:pos_mobile_app/providers/cart_provider.dart';
import 'package:pos_mobile_app/models/product.dart';

void main() {
  group('CartScreen Widget Tests', () {
    testWidgets('Empty cart shows message', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('Cart displays items', (WidgetTester tester) async {
      final cartProvider = CartProvider();
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
      cartProvider.addItem(product, 2, null);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => cartProvider,
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('RM 50.00'), findsOneWidget);
    });

    testWidgets('Remove item from cart', (WidgetTester tester) async {
      final cartProvider = CartProvider();
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
      cartProvider.addItem(product, 2, null);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => cartProvider,
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      // Find and tap remove button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });
  });
}
```

### Running Widget Tests

```bash
# Run all widget tests
flutter test test/screens/

# Run specific widget test
flutter test test/screens/home_screen_test.dart

# Run with verbose output
flutter test test/screens/ --verbose
```

## Integration Testing

Integration tests verify the entire app flow works correctly.

### Create Integration Test

Create `integration_test/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_mobile_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('POS App Integration Tests', () {
    testWidgets('Complete purchase flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify home screen is displayed
      expect(find.text('Welcome to POS System'), findsOneWidget);

      // Navigate to products
      await tester.tap(find.text('Browse Products'));
      await tester.pumpAndSettle();

      // Verify products screen
      expect(find.byType(ListView), findsWidgets);

      // Add product to cart
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();
      }

      // Navigate to cart
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verify cart screen
      expect(find.text('Shopping Cart'), findsOneWidget);

      // Proceed to checkout
      final checkoutButton = find.byType(ElevatedButton);
      if (checkoutButton.evaluate().isNotEmpty) {
        await tester.tap(checkoutButton.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Search products functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to products
      await tester.tap(find.text('Browse Products'));
      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'test');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.byType(ListView), findsWidgets);
      }
    });

    testWidgets('Customer selection in checkout', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to checkout (simplified)
      // This would require adding a product first
      // Then navigating to checkout
      // Then selecting a customer

      // Verify customer selection dialog appears
      // (Implementation depends on your UI)
    });
  });
}
```

### Running Integration Tests

```bash
# Run integration tests on Android emulator
flutter test integration_test/app_test.dart -d emulator-5554

# Run integration tests on iOS simulator
flutter test integration_test/app_test.dart -d iPhone

# Run on physical device
flutter test integration_test/app_test.dart -d <device_id>

# Generate integration test report
flutter test integration_test/ --verbose
```

## Manual Testing

### 1. Test on Emulator/Simulator

```bash
# Start Android emulator
emulator -avd <emulator_name>

# Start iOS simulator
open -a Simulator

# Run app on emulator
flutter run -d emulator-5554

# Run app on simulator
flutter run -d iPhone
```

### 2. Test on Physical Device

```bash
# Connect device via USB
# Enable USB debugging on Android
# Trust device on iOS

# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### 3. Manual Test Cases

#### Test Case 1: Product Browsing
- [ ] Launch app
- [ ] Navigate to Products screen
- [ ] Verify all products are displayed
- [ ] Search for a product by name
- [ ] Verify search results
- [ ] Tap on a product to view details
- [ ] Verify product information is correct

#### Test Case 2: Add to Cart
- [ ] Navigate to Products
- [ ] Add a product to cart
- [ ] Verify item appears in cart
- [ ] Add another product
- [ ] Verify total is calculated correctly
- [ ] Update quantity of an item
- [ ] Verify total updates

#### Test Case 3: Checkout
- [ ] Add items to cart
- [ ] Navigate to checkout
- [ ] Select payment method (Cash)
- [ ] Complete purchase
- [ ] Verify order confirmation
- [ ] Verify cart is cleared

#### Test Case 4: Credit Payment
- [ ] Add items to cart
- [ ] Navigate to checkout
- [ ] Select payment method (Credit)
- [ ] Select a customer
- [ ] Verify customer credit balance is displayed
- [ ] Complete purchase
- [ ] Verify credit balance is updated

#### Test Case 5: Weighing Scale
- [ ] Connect Bluetooth scale
- [ ] Navigate to weighable products
- [ ] Place item on scale
- [ ] Verify weight is displayed
- [ ] Add weighted item to cart
- [ ] Verify weight is recorded

#### Test Case 6: Error Handling
- [ ] Disconnect internet
- [ ] Try to load products
- [ ] Verify error message is displayed
- [ ] Reconnect internet
- [ ] Verify app recovers

## Testing Checklist

### Pre-Release Testing

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] All integration tests pass
- [ ] Code analyzer shows no errors
- [ ] No console warnings
- [ ] App launches without crashes
- [ ] All screens render correctly
- [ ] Navigation works properly
- [ ] API calls work correctly
- [ ] Error handling works
- [ ] Bluetooth connectivity works
- [ ] Cart calculations are correct
- [ ] Payment processing works
- [ ] Customer selection works
- [ ] Receipt generation works

### Device Testing

- [ ] Test on Android emulator
- [ ] Test on iOS simulator
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Test on different screen sizes
- [ ] Test on different Android versions
- [ ] Test on different iOS versions
- [ ] Test with slow internet
- [ ] Test offline mode (if implemented)
- [ ] Test with Bluetooth scale

### Performance Testing

- [ ] App launches in < 3 seconds
- [ ] Screens load in < 2 seconds
- [ ] Scrolling is smooth (60 FPS)
- [ ] No memory leaks
- [ ] Battery usage is reasonable
- [ ] Network requests are optimized

### Security Testing

- [ ] API credentials are not exposed
- [ ] Sensitive data is encrypted
- [ ] User input is validated
- [ ] SQL injection is prevented
- [ ] XSS attacks are prevented
- [ ] HTTPS is used for API calls

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter test integration_test/
```

## Troubleshooting Tests

### Common Issues

**Tests fail with "No Material widget found"**
- Wrap test widget with MaterialApp

**Tests timeout**
- Increase timeout: `tester.pumpAndSettle(timeout: Duration(seconds: 5))`

**Provider not found**
- Wrap widget with MultiProvider in test

**API calls fail in tests**
- Mock API responses using mockito

**Bluetooth tests fail**
- Mock BluetoothService in tests

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Flutter Test Package](https://pub.dev/packages/flutter_test)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Mockito Package](https://pub.dev/packages/mockito)

---

**Ready to test?** Start with unit tests, then move to widget tests, and finally integration tests!

