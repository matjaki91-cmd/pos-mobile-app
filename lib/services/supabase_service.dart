import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;
  
  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // ==================== PRODUCTS ====================
  
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<Product> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      print('Error fetching product: $e');
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', id)
          .select()
          .single();
      
      return Product.fromJson(response);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== CUSTOMERS ====================
  
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => Customer.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching customers: $e');
      rethrow;
    }
  }

  Future<Customer> getCustomer(String id) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .eq('id', id)
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      print('Error fetching customer: $e');
      rethrow;
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await _client
          .from('customers')
          .insert(customer.toJson())
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      print('Error creating customer: $e');
      rethrow;
    }
  }

  Future<Customer> updateCustomer(String id, Customer customer) async {
    try {
      final response = await _client
          .from('customers')
          .update(customer.toJson())
          .eq('id', id)
          .select()
          .single();
      
      return Customer.fromJson(response);
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  // ==================== ORDERS ====================
  
  Future<List<Order>> getOrders() async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<Order> getOrder(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', id)
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      print('Error fetching order: $e');
      rethrow;
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      // Insert order
      final orderResponse = await _client
          .from('orders')
          .insert({
            'customer_id': order.customerId,
            'total_amount': order.totalAmount,
            'payment_method': order.paymentMethod,
            'status': order.status,
          })
          .select()
          .single();
      
      final orderId = orderResponse['id'];
      
      // Insert order items
      if (order.items.isNotEmpty) {
        final itemsData = order.items.map((item) => {
          'order_id': orderId,
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
        }).toList();
        
        await _client
            .from('order_items')
            .insert(itemsData);
      }
      
      // If payment method is credit, create credit transaction
      if (order.paymentMethod == 'credit' && order.customerId != null) {
        await _client
            .from('credit_transactions')
            .insert({
              'customer_id': order.customerId,
              'order_id': orderId,
              'amount': order.totalAmount,
              'type': 'charge',
              'notes': 'Order #$orderId',
            });
      }
      
      // Fetch complete order with items
      return await getOrder(orderId);
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final response = await _client
          .from('orders')
          .update({'status': status})
          .eq('id', id)
          .select('*, order_items(*)')
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // ==================== STOCK MOVEMENTS ====================
  
  Future<void> recordStockMovement({
    required String productId,
    required String type, // 'in' or 'out'
    required int quantity,
    String? supplier,
    String? reference,
    String? reason,
  }) async {
    try {
      await _client
          .from('stock_movements')
          .insert({
            'product_id': productId,
            'type': type,
            'quantity': quantity,
            'supplier': supplier,
            'reference': reference,
            'reason': reason,
          });
    } catch (e) {
      print('Error recording stock movement: $e');
      rethrow;
    }
  }

  // ==================== CREDIT TRANSACTIONS ====================
  
  Future<void> recordCreditPayment({
    required String customerId,
    required double amount,
    String? notes,
  }) async {
    try {
      await _client
          .from('credit_transactions')
          .insert({
            'customer_id': customerId,
            'amount': amount,
            'type': 'payment',
            'notes': notes,
          });
    } catch (e) {
      print('Error recording credit payment: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerCreditTransactions(String customerId) async {
    try {
      final response = await _client
          .from('credit_transactions')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching credit transactions: $e');
      rethrow;
    }
  }

  // ==================== AUTHENTICATION ====================
  
  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  User? get currentUser => _client.auth.currentUser;
  
  bool get isAuthenticated => _client.auth.currentUser != null;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

