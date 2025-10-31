import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:image/image.dart' as img;
import '../models/order.dart';

class ReceiptPrinterService {
  static final ReceiptPrinterService _instance = ReceiptPrinterService._internal();
  factory ReceiptPrinterService() => _instance;
  ReceiptPrinterService._internal();

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  PrinterBluetooth? _selectedPrinter;

  /// Scan for available Bluetooth printers
  Future<List<PrinterBluetooth>> scanPrinters() async {
    try {
      final printers = await _printerManager.startScan(Duration(seconds: 4));
      return printers;
    } catch (e) {
      print('Error scanning printers: $e');
      throw Exception('Failed to scan for printers: $e');
    }
  }

  /// Connect to a printer
  Future<bool> connect(PrinterBluetooth printer) async {
    try {
      _selectedPrinter = printer;
      return true;
    } catch (e) {
      print('Error connecting to printer: $e');
      return false;
    }
  }

  /// Disconnect from printer
  Future<void> disconnect() async {
    _selectedPrinter = null;
  }

  /// Print receipt for an order
  Future<bool> printReceipt({
    required Order order,
    required String companyName,
    required String companyAddress,
    required String companyPhone,
    required String companyTaxId,
    String? qrCodeData,
  }) async {
    if (_selectedPrinter == null) {
      throw Exception('No printer connected');
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      // Header
      bytes += generator.text(
        companyName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        companyAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Tel: $companyPhone',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text(
        'Tax ID: $companyTaxId',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.hr();
      
      // Receipt info
      bytes += generator.text(
        'SALES RECEIPT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      
      bytes += generator.row([
        PosColumn(
          text: 'Receipt No:',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: order.id.substring(0, 8).toUpperCase(),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      
      bytes += generator.row([
        PosColumn(
          text: 'Date:',
          width: 6,
        ),
        PosColumn(
          text: _formatDateTime(order.createdAt),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      
      if (order.customerId != null) {
        bytes += generator.row([
          PosColumn(
            text: 'Customer:',
            width: 6,
          ),
          PosColumn(
            text: order.customerId!,
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      
      bytes += generator.hr();
      
      // Items header
      bytes += generator.row([
        PosColumn(text: 'Item', width: 6),
        PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.hr(ch: '-');
      
      // Items
      for (final item in order.items) {
        bytes += generator.row([
          PosColumn(text: item.productName, width: 6),
          PosColumn(
            text: item.quantity.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: item.unitPrice.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: item.totalPrice.toStringAsFixed(2),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      
      bytes += generator.hr();
      
      // Totals
      bytes += generator.row([
        PosColumn(text: 'Subtotal:', width: 8),
        PosColumn(
          text: 'RM ${order.totalAmount.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      
      if (order.discountAmount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Discount:', width: 8),
          PosColumn(
            text: '- RM ${order.discountAmount.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      
      if (order.taxAmount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Tax (6%):', width: 8),
          PosColumn(
            text: 'RM ${order.taxAmount.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      
      bytes += generator.hr(ch: '=');
      
      final grandTotal = order.totalAmount - order.discountAmount + order.taxAmount;
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL:',
          width: 8,
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true,
          ),
        ),
        PosColumn(
          text: 'RM ${grandTotal.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true,
          ),
        ),
      ]);
      
      bytes += generator.hr(ch: '=');
      
      // Payment info
      bytes += generator.row([
        PosColumn(text: 'Payment Method:', width: 6),
        PosColumn(
          text: order.paymentMethod.toUpperCase(),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      
      bytes += generator.hr();
      
      // QR Code for LHDN (if provided)
      if (qrCodeData != null) {
        bytes += generator.text(
          'Scan for e-Invoice',
          styles: const PosStyles(align: PosAlign.center, bold: true),
        );
        
        // Note: QR code generation requires additional setup
        // bytes += generator.qrcode(qrCodeData);
        
        bytes += generator.text(
          qrCodeData,
          styles: const PosStyles(align: PosAlign.center, font: PosFontType.fontA),
        );
        
        bytes += generator.hr();
      }
      
      // Footer
      bytes += generator.text(
        'Thank you for your purchase!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text(
        'Please come again',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.feed(2);
      bytes += generator.cut();
      
      // Send to printer
      await _printerManager.writeBytes(Uint8List.fromList(bytes));
      
      return true;
    } catch (e) {
      print('Error printing receipt: $e');
      throw Exception('Failed to print receipt: $e');
    }
  }

  /// Print weighing label
  Future<bool> printWeighingLabel({
    required String productName,
    required double weight,
    required String unit,
    required double pricePerUnit,
    required double totalPrice,
    String? barcode,
  }) async {
    if (_selectedPrinter == null) {
      throw Exception('No printer connected');
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile); // Smaller paper for labels
      List<int> bytes = [];

      bytes += generator.text(
        productName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      bytes += generator.hr();
      
      bytes += generator.text(
        'Weight: ${weight.toStringAsFixed(2)} $unit',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text(
        'Price/Unit: RM ${pricePerUnit.toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.hr();
      
      bytes += generator.text(
        'TOTAL: RM ${totalPrice.toStringAsFixed(2)}',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      if (barcode != null) {
        bytes += generator.hr();
        // bytes += generator.barcode(Barcode.ean13(barcode));
        bytes += generator.text(
          barcode,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.text(
        DateTime.now().toString().substring(0, 19),
        styles: const PosStyles(align: PosAlign.center, font: PosFontType.fontA),
      );
      
      bytes += generator.feed(2);
      bytes += generator.cut();
      
      await _printerManager.writeBytes(Uint8List.fromList(bytes));
      
      return true;
    } catch (e) {
      print('Error printing label: $e');
      throw Exception('Failed to print label: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

