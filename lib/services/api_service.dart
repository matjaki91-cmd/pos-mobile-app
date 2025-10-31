import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  // Product endpoints
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/api/trpc/product.list');
      if (response.statusCode == 200) {
        final data = response.data['result']['data'] as List;
        return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _dio.get(
        '/api/trpc/product.get',
        queryParameters: {'input': '{"id":"$id"}'},
      );
      if (response.statusCode == 200) {
        return Product.fromJson(response.data['result']['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Customer endpoints
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _dio.get('/api/trpc/customer.list');
      if (response.statusCode == 200) {
        final data = response.data['result']['data'] as List;
        return data.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load customers');
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      final response = await _dio.get(
        '/api/trpc/customer.get',
        queryParameters: {'input': '{"id":"$id"}'},
      );
      if (response.statusCode == 200) {
        return Customer.fromJson(response.data['result']['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  Future<Customer> createCustomer({
    required String name,
    String? phoneNumber,
    String? email,
    String? address,
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/customer.create',
        data: {
          'input': {
            'name': name,
            'phoneNumber': phoneNumber,
            'email': email,
            'address': address,
          }
        },
      );
      if (response.statusCode == 200) {
        return Customer.fromJson(response.data['result']['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create customer');
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  // Order endpoints
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/api/trpc/order.list');
      if (response.statusCode == 200) {
        final data = response.data['result']['data'] as List;
        return data.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<Order> createOrder({
    String? customerId,
    required List<Map<String, dynamic>> items,
    String? paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/order.create',
        data: {
          'input': {
            'customerId': customerId,
            'items': items,
            'paymentMethod': paymentMethod,
          }
        },
      );
      if (response.statusCode == 200) {
        return Order.fromJson(response.data['result']['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create order');
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Inventory endpoints
  Future<void> recordStockMovement({
    required String productId,
    required double quantity,
    required bool hasSupplier,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/inventory.recordInbound',
        data: {
          'input': {
            'productId': productId,
            'quantity': quantity.toString(),
            'hasSupplier': hasSupplier,
            'notes': notes,
          }
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to record stock movement');
      }
    } catch (e) {
      throw Exception('Error recording stock movement: $e');
    }
  }

  // Credit endpoints
  Future<void> recordCreditTransaction({
    required String customerId,
    required double amount,
    required String transactionType,
    String? orderId,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/trpc/credit.recordTransaction',
        data: {
          'input': {
            'customerId': customerId,
            'amount': amount.toString(),
            'transactionType': transactionType,
            'orderId': orderId,
            'description': description,
          }
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to record credit transaction');
      }
    } catch (e) {
      throw Exception('Error recording credit transaction: $e');
    }
  }
}

