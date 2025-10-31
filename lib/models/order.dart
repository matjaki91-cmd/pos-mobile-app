class Order {
  final String id;
  final String? customerId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String? paymentMethod;
  final bool isLhdnSubmitted;
  final String? lhdnInvoiceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    this.customerId,
    required this.orderDate,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentMethod,
    this.isLhdnSubmitted = false,
    this.lhdnInvoiceId,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customerId'] as String?,
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalAmount: double.parse(json['totalAmount'].toString()),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String?,
      isLhdnSubmitted: json['isLhdnSubmitted'] as bool? ?? false,
      lhdnInvoiceId: json['lhdnInvoiceId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'isLhdnSubmitted': isLhdnSubmitted,
      'lhdnInvoiceId': lhdnInvoiceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      quantity: double.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unitPrice'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

