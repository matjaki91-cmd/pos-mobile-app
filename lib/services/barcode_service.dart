import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  /// Scan barcode using camera
  Future<String?> scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan(
        options: const ScanOptions(
          strings: {
            'cancel': 'Cancel',
            'flash_on': 'Flash On',
            'flash_off': 'Flash Off',
          },
          restrictFormat: [
            BarcodeFormat.ean8,
            BarcodeFormat.ean13,
            BarcodeFormat.code39,
            BarcodeFormat.code128,
            BarcodeFormat.qr,
            BarcodeFormat.upcA,
            BarcodeFormat.upcE,
          ],
          useCamera: -1, // -1 = default camera
          autoEnableFlash: false,
          android: AndroidOptions(
            aspectTolerance: 0.00,
            useAutoFocus: true,
          ),
        ),
      );

      if (result.type == ResultType.Barcode) {
        return result.rawContent;
      } else if (result.type == ResultType.Cancelled) {
        print('Barcode scan cancelled by user');
        return null;
      } else if (result.type == ResultType.Error) {
        print('Barcode scan error: ${result.rawContent}');
        throw Exception('Barcode scan failed: ${result.rawContent}');
      }
      
      return null;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        throw Exception('Camera permission denied. Please enable camera access in settings.');
      } else {
        throw Exception('Error scanning barcode: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during barcode scan: $e');
      rethrow;
    }
  }

  /// Validate barcode format
  bool isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;
    
    // EAN-13 (13 digits)
    if (RegExp(r'^\d{13}$').hasMatch(barcode)) return true;
    
    // EAN-8 (8 digits)
    if (RegExp(r'^\d{8}$').hasMatch(barcode)) return true;
    
    // UPC-A (12 digits)
    if (RegExp(r'^\d{12}$').hasMatch(barcode)) return true;
    
    // UPC-E (6-8 digits)
    if (RegExp(r'^\d{6,8}$').hasMatch(barcode)) return true;
    
    // Code 39 (alphanumeric)
    if (RegExp(r'^[A-Z0-9\-\.\ \$\/\+\%]+$').hasMatch(barcode)) return true;
    
    // Code 128 (any ASCII)
    if (barcode.length > 0) return true;
    
    return false;
  }

  /// Get barcode format name
  String getBarcodeFormat(String barcode) {
    if (RegExp(r'^\d{13}$').hasMatch(barcode)) return 'EAN-13';
    if (RegExp(r'^\d{8}$').hasMatch(barcode)) return 'EAN-8';
    if (RegExp(r'^\d{12}$').hasMatch(barcode)) return 'UPC-A';
    if (RegExp(r'^\d{6,8}$').hasMatch(barcode)) return 'UPC-E';
    if (RegExp(r'^[A-Z0-9\-\.\ \$\/\+\%]+$').hasMatch(barcode)) return 'Code 39';
    return 'Code 128';
  }

  /// Calculate EAN-13 checksum
  bool validateEAN13(String barcode) {
    if (barcode.length != 13) return false;
    
    try {
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        int digit = int.parse(barcode[i]);
        sum += (i % 2 == 0) ? digit : digit * 3;
      }
      
      int checksum = (10 - (sum % 10)) % 10;
      return checksum == int.parse(barcode[12]);
    } catch (e) {
      return false;
    }
  }

  /// Calculate UPC-A checksum
  bool validateUPCA(String barcode) {
    if (barcode.length != 12) return false;
    
    try {
      int sum = 0;
      for (int i = 0; i < 11; i++) {
        int digit = int.parse(barcode[i]);
        sum += (i % 2 == 0) ? digit * 3 : digit;
      }
      
      int checksum = (10 - (sum % 10)) % 10;
      return checksum == int.parse(barcode[11]);
    } catch (e) {
      return false;
    }
  }

  /// Generate random barcode for testing
  String generateTestBarcode({String format = 'EAN13'}) {
    if (format == 'EAN13') {
      // Generate 12 random digits
      String barcode = '';
      for (int i = 0; i < 12; i++) {
        barcode += (DateTime.now().millisecondsSinceEpoch % 10).toString();
      }
      
      // Calculate checksum
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        int digit = int.parse(barcode[i]);
        sum += (i % 2 == 0) ? digit : digit * 3;
      }
      int checksum = (10 - (sum % 10)) % 10;
      
      return barcode + checksum.toString();
    } else if (format == 'UPC-A') {
      // Generate 11 random digits
      String barcode = '';
      for (int i = 0; i < 11; i++) {
        barcode += (DateTime.now().millisecondsSinceEpoch % 10).toString();
      }
      
      // Calculate checksum
      int sum = 0;
      for (int i = 0; i < 11; i++) {
        int digit = int.parse(barcode[i]);
        sum += (i % 2 == 0) ? digit * 3 : digit;
      }
      int checksum = (10 - (sum % 10)) % 10;
      
      return barcode + checksum.toString();
    }
    
    return '1234567890123'; // Default EAN-13
  }
}

