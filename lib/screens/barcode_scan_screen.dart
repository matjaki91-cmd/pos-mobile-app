import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/barcode_service.dart';
import '../services/supabase_service.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final BarcodeService _barcodeService = BarcodeService();
  final SupabaseService _supabase = SupabaseService();
  
  String? _lastScannedBarcode;
  Product? _foundProduct;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _scanBarcode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundProduct = null;
    });

    try {
      final barcode = await _barcodeService.scanBarcode();
      
      if (barcode != null && barcode.isNotEmpty) {
        setState(() {
          _lastScannedBarcode = barcode;
        });
        
        await _searchProductByBarcode(barcode);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProductByBarcode(String barcode) async {
    try {
      // Search product by barcode in database
      final products = await _supabase.client
          .from('products')
          .select()
          .eq('barcode', barcode)
          .limit(1);
      
      if (products.isNotEmpty) {
        setState(() {
          _foundProduct = Product.fromJson(products.first);
        });
      } else {
        setState(() {
          _errorMessage = 'Product not found for barcode: $barcode';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching product: $e';
      });
    }
  }

  void _addToCart() {
    if (_foundProduct != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addItem(_foundProduct!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_foundProduct!.name} added to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Clear found product and scan again
      setState(() {
        _foundProduct = null;
        _lastScannedBarcode = null;
      });
      
      // Auto scan next product
      Future.delayed(const Duration(milliseconds: 500), () {
        _scanBarcode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scan button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner, size: 32),
                label: Text(
                  _isLoading ? 'Scanning...' : 'Scan Barcode',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Last scanned barcode
              if (_lastScannedBarcode != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scanned Barcode:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastScannedBarcode!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Format: ${_barcodeService.getBarcodeFormat(_lastScannedBarcode!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Loading indicator
              if (_isLoading) ...[
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Error message
              if (_errorMessage != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Found product
              if (_foundProduct != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Product Found!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          _foundProduct!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_foundProduct!.sku != null) ...[
                          Text(
                            'SKU: ${_foundProduct!.sku}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Price: RM ${_foundProduct!.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock: ${_foundProduct!.stockQuantity} ${_foundProduct!.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Instructions
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Text(
                            'How to use',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Tap "Scan Barcode" button\n'
                        '2. Point camera at product barcode\n'
                        '3. Wait for auto-focus and scan\n'
                        '4. Product will be added to cart automatically',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

