import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/supabase_service.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'dart:async';

class WeighingScaleScreen extends StatefulWidget {
  const WeighingScaleScreen({super.key});

  @override
  State<WeighingScaleScreen> createState() => _WeighingScaleScreenState();
}

class _WeighingScaleScreenState extends State<WeighingScaleScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  final SupabaseService _supabase = SupabaseService();
  
  List<Product> _weighableProducts = [];
  Product? _selectedProduct;
  double _currentWeight = 0.0;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _connectedDeviceName;
  StreamSubscription? _weightSubscription;

  @override
  void initState() {
    super.initState();
    _loadWeighableProducts();
  }

  @override
  void dispose() {
    _weightSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadWeighableProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _supabase.client
          .from('products')
          .select()
          .eq('is_weighable', true)
          .order('name');
      
      setState(() {
        _weighableProducts = products.map((json) => Product.fromJson(json)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading products: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToScale() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _bluetoothService.scanAndConnect();
      
      setState(() {
        _isConnected = true;
        _connectedDeviceName = _bluetoothService.connectedDeviceName;
      });
      
      // Start listening to weight updates
      _weightSubscription = _bluetoothService.weightStream.listen((weight) {
        setState(() {
          _currentWeight = weight;
        });
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to $_connectedDeviceName'),
          backgroundColor: Colors.green,
        ),
      );
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

  Future<void> _disconnect() async {
    await _bluetoothService.disconnect();
    _weightSubscription?.cancel();
    
    setState(() {
      _isConnected = false;
      _connectedDeviceName = null;
      _currentWeight = 0.0;
    });
  }

  void _addToCart() {
    if (_selectedProduct != null && _currentWeight > 0) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addWeighableItem(_selectedProduct!, _currentWeight);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_currentWeight.toStringAsFixed(2)} ${_selectedProduct!.unit} of ${_selectedProduct!.name} added to cart',
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset selection
      setState(() {
        _selectedProduct = null;
        _currentWeight = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weighing Scale'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.bluetooth_connected),
              onPressed: _disconnect,
              tooltip: 'Disconnect',
            )
          else
            IconButton(
              icon: const Icon(Icons.bluetooth),
              onPressed: _connectToScale,
              tooltip: 'Connect to Scale',
            ),
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
              // Connection status
              Card(
                color: _isConnected ? Colors.green.shade50 : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: _isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isConnected ? 'Connected' : 'Not Connected',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                              ),
                            ),
                            if (_connectedDeviceName != null)
                              Text(
                                _connectedDeviceName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!_isConnected)
                        ElevatedButton(
                          onPressed: _isLoading ? null : _connectToScale,
                          child: const Text('Connect'),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Weight display
              Card(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Weight',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentWeight.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        _selectedProduct?.unit ?? 'kg',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Product selection
              const Text(
                'Select Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _weighableProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No weighable products found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _weighableProducts.length,
                            itemBuilder: (context, index) {
                              final product = _weighableProducts[index];
                              final isSelected = _selectedProduct?.id == product.id;
                              
                              return Card(
                                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.scale,
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'RM ${product.price.toStringAsFixed(2)} per ${product.unit}',
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedProduct = product;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
              
              const SizedBox(height: 16),
              
              // Error message
              if (_errorMessage != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Add to cart button
              ElevatedButton.icon(
                onPressed: (_isConnected && _selectedProduct != null && _currentWeight > 0)
                    ? _addToCart
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

