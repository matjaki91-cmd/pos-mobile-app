class ApiConfig {
  // Replace with your deployed backend URL
  static const String baseUrl = 'http://localhost:3000';
  
  // API Endpoints
  static const String productsEndpoint = '/api/trpc/product.list';
  static const String customersEndpoint = '/api/trpc/customer.list';
  static const String ordersEndpoint = '/api/trpc/order.list';
  static const String inventoryEndpoint = '/api/trpc/inventory.stockMovements';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // App Info
  static const String appName = 'POS System';
  static const String appVersion = '1.0.0';
}

