import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      return await _apiService.getProductById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) {
      return _products;
    }
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            (product.barcode?.contains(query) ?? false) ||
            (product.sku?.contains(query) ?? false))
        .toList();
  }

  List<Product> getWeighableProducts() {
    return _products.where((product) => product.isWeighable).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

