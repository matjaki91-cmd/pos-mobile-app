# Receipt Generation and LHDN Integration Guide

This document provides detailed instructions for implementing receipt generation and LHDN e-invoicing integration in the POS mobile app.

## Receipt Generation

### Overview

The POS system generates receipts in two formats:
1. **Digital Receipt**: PDF format for email/storage
2. **Printed Receipt**: Thermal printer format for counter printing

### Receipt Format (LHDN Compliant)

```
═══════════════════════════════════════════
           COMPANY NAME
        Business Registration No.
═══════════════════════════════════════════

Date: 2024-10-19 14:30:45
Invoice No: INV-2024-001234
Cashier: John Doe

───────────────────────────────────────────
ITEMS
───────────────────────────────────────────
Product Name              Qty    Price   Total
Item 1                    2.00   50.00   100.00
Item 2 (Weighable)        1.50kg 80.00   120.00
Item 3                    1.00   75.00   75.00

───────────────────────────────────────────
SUBTOTAL                              295.00
Service Tax (6%)                       17.70
TOTAL                                312.70

───────────────────────────────────────────
PAYMENT METHOD: Cash
Amount Paid: 312.70
Change: 0.00

Customer: John Customer
Phone: 012-3456789

───────────────────────────────────────────
LHDN E-Invoice QR Code
[QR CODE IMAGE]

Scan QR code to verify invoice with LHDN
Invoice ID: INV-2024-001234

═══════════════════════════════════════════
Thank you for your purchase!
═══════════════════════════════════════════
```

### Implementation

Create a receipt service:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiptService {
  Future<void> generateAndPrintReceipt({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
    required String businessRegNo,
    required String cashierName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Business Reg: $businessRegNo',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),

              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date: ${DateTime.now()}'),
                  pw.Text('Invoice: ${order.id.substring(0, 8)}'),
                ],
              ),
              pw.Text('Cashier: $cashierName'),
              pw.SizedBox(height: 10),

              // Items
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    children: [
                      pw.Text('Item'),
                      pw.Text('Qty'),
                      pw.Text('Price'),
                      pw.Text('Total'),
                    ],
                  ),
                  // Items
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Text(item.productId),
                        pw.Text(item.quantity.toString()),
                        pw.Text('${item.unitPrice}'),
                        pw.Text('${item.subtotal}'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 10),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:'),
                  pw.Text('RM ${order.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 10),

              // Payment Method
              pw.Text('Payment: ${order.paymentMethod}'),
              pw.SizedBox(height: 10),

              // QR Code (placeholder)
              pw.Text('LHDN E-Invoice'),
              pw.SizedBox(height: 5),
            ],
          );
        },
      ),
    );

    // Print or save
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateReceiptPDF({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Invoice: ${order.id}'),
              pw.Text('Date: ${order.orderDate}'),
              pw.SizedBox(height: 20),
              // Add items table
              pw.SizedBox(height: 20),
              pw.Text('Total: RM ${order.totalAmount.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    // Save to file
    // final output = await getApplicationDocumentsDirectory();
    // final file = File('${output.path}/receipt_${order.id}.pdf');
    // await file.writeAsBytes(await pdf.save());
  }
}
```

## LHDN E-Invoicing Integration

### Overview

LHDN (Lembaga Hasil Dalam Negeri - Malaysian Inland Revenue Board) requires e-invoicing for all businesses. The POS system integrates with LHDN's MyInvois API.

### Requirements

1. **Business Registration**: Valid Malaysian business registration
2. **TIN Number**: Tax Identification Number
3. **API Credentials**: LHDN API key and secret
4. **Digital Certificate**: For signing invoices

### LHDN API Integration

Create an LHDN service:

```dart
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

class LHDNService {
  final Dio _dio;
  final String _apiKey;
  final String _apiSecret;
  final String _businessTIN;

  LHDNService({
    required String apiKey,
    required String apiSecret,
    required String businessTIN,
  })  : _apiKey = apiKey,
        _apiSecret = apiSecret,
        _businessTIN = businessTIN,
        _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.myinvois.hasil.gov.my',
            contentType: 'application/json',
          ),
        );

  /// Submit invoice to LHDN
  Future<String?> submitInvoice({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
    required String companyAddress,
  }) async {
    try {
      // Prepare invoice data
      final invoiceData = _prepareInvoiceData(
        order: order,
        items: items,
        companyName: companyName,
        companyAddress: companyAddress,
      );

      // Sign invoice
      final signedData = _signInvoice(invoiceData);

      // Submit to LHDN
      final response = await _dio.post(
        '/api/v1.0/invoices/submit',
        data: signedData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'X-Signature': _generateSignature(signedData),
          },
        ),
      );

      if (response.statusCode == 200) {
        final invoiceId = response.data['invoiceId'];
        return invoiceId;
      }
      return null;
    } catch (e) {
      print('Error submitting invoice to LHDN: $e');
      return null;
    }
  }

  /// Generate QR code for invoice
  Future<String> generateQRCode({
    required String invoiceId,
    required String tinNumber,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1.0/invoices/$invoiceId/qr',
        queryParameters: {
          'tin': tinNumber,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['qrCode'];
      }
      return '';
    } catch (e) {
      print('Error generating QR code: $e');
      return '';
    }
  }

  /// Verify invoice status
  Future<bool> verifyInvoice({
    required String invoiceId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1.0/invoices/$invoiceId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['status'] == 'VALID';
      }
      return false;
    } catch (e) {
      print('Error verifying invoice: $e');
      return false;
    }
  }

  Map<String, dynamic> _prepareInvoiceData({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
    required String companyAddress,
  }) {
    return {
      'invoiceId': order.id,
      'invoiceDate': order.orderDate.toIso8601String(),
      'supplier': {
        'name': companyName,
        'address': companyAddress,
        'tin': _businessTIN,
      },
      'items': items
          .map((item) => {
                'description': 'Product',
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'amount': item.subtotal,
              })
          .toList(),
      'totalAmount': order.totalAmount,
      'paymentMethod': order.paymentMethod,
    };
  }

  String _signInvoice(Map<String, dynamic> data) {
    // Implement digital signature
    // This requires a digital certificate
    return jsonEncode(data);
  }

  String _generateSignature(String data) {
    // Generate HMAC signature
    final bytes = utf8.encode(data);
    final key = utf8.encode(_apiSecret);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
}
```

### Integration with Checkout

```dart
class CheckoutScreen extends StatefulWidget {
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _apiService = ApiService();
  final LHDNService _lhdnService = LHDNService(
    apiKey: 'YOUR_LHDN_API_KEY',
    apiSecret: 'YOUR_LHDN_API_SECRET',
    businessTIN: 'YOUR_BUSINESS_TIN',
  );

  Future<void> _completeCheckout(Order order, List<OrderItem> items) async {
    try {
      // Submit to LHDN if enabled
      final lhdnInvoiceId = await _lhdnService.submitInvoice(
        order: order,
        items: items,
        companyName: 'Your Company Name',
        companyAddress: 'Your Company Address',
      );

      if (lhdnInvoiceId != null) {
        // Generate QR code
        final qrCode = await _lhdnService.generateQRCode(
          invoiceId: lhdnInvoiceId,
          tinNumber: 'CUSTOMER_TIN',
        );

        // Update order with LHDN info
        // Save QR code to order
      }

      // Generate receipt
      // Print or email receipt
    } catch (e) {
      print('Error completing checkout: $e');
    }
  }
}
```

## Receipt Printing

### Thermal Printer Integration

```dart
class PrinterService {
  Future<void> printReceipt({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
  }) async {
    // Use flutter_thermal_printer or similar package
    // Format receipt for 80mm thermal printer
    
    final receipt = _formatReceiptForPrinter(
      order: order,
      items: items,
      companyName: companyName,
    );

    // Send to printer
    // await printer.printText(receipt);
  }

  String _formatReceiptForPrinter({
    required Order order,
    required List<OrderItem> items,
    required String companyName,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('═' * 40);
    buffer.writeln(companyName.padCenter(40));
    buffer.writeln('═' * 40);
    buffer.writeln('');
    buffer.writeln('Date: ${DateTime.now()}');
    buffer.writeln('Invoice: ${order.id.substring(0, 8)}');
    buffer.writeln('');
    buffer.writeln('─' * 40);
    buffer.writeln('ITEMS');
    buffer.writeln('─' * 40);

    for (final item in items) {
      buffer.writeln('Item: ${item.productId}');
      buffer.writeln('Qty: ${item.quantity} x RM ${item.unitPrice}');
      buffer.writeln('Subtotal: RM ${item.subtotal.toStringAsFixed(2)}');
      buffer.writeln('');
    }

    buffer.writeln('─' * 40);
    buffer.writeln('TOTAL: RM ${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('Payment: ${order.paymentMethod}');
    buffer.writeln('─' * 40);
    buffer.writeln('');
    buffer.writeln('Thank you for your purchase!');
    buffer.writeln('═' * 40);

    return buffer.toString();
  }
}

extension on String {
  String padCenter(int width) {
    final padding = (width - length) ~/ 2;
    return ' ' * padding + this + ' ' * padding;
  }
}
```

## QR Code Generation

```dart
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  final String invoiceId;
  final String tinNumber;

  const QRCodeWidget({
    Key? key,
    required this.invoiceId,
    required this.tinNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: 'https://myinvois.hasil.gov.my/verify/$invoiceId/$tinNumber',
      version: QrVersions.auto,
      size: 200.0,
      gapless: false,
    );
  }
}
```

## Configuration

Add LHDN credentials to your configuration:

```dart
// lib/config/lhdn_config.dart
class LHDNConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiSecret = 'YOUR_API_SECRET';
  static const String businessTIN = 'YOUR_BUSINESS_TIN';
  static const String businessName = 'YOUR_BUSINESS_NAME';
  static const String businessAddress = 'YOUR_BUSINESS_ADDRESS';
  static const bool enableLHDN = true;
}
```

## Testing

Test LHDN integration with:

1. **Sandbox Environment**: Use LHDN sandbox API for testing
2. **Test Invoices**: Create test invoices and verify QR codes
3. **Error Handling**: Test network failures and API errors
4. **Receipt Generation**: Verify receipt format and QR codes

## References

- [LHDN MyInvois API Documentation](https://myinvois.hasil.gov.my)
- [E-Invoice Format Specification](https://www.hasil.gov.my)
- [PDF Generation Package](https://pub.dev/packages/pdf)
- [QR Code Package](https://pub.dev/packages/qr_flutter)

