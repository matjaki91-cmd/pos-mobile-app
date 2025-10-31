class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? sku;
  final String? barcode;
  final String unitOfMeasure;
  final double stockQuantity;
  final bool isWeighable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.sku,
    this.barcode,
    this.unitOfMeasure = 'pcs',
    this.stockQuantity = 0,
    this.isWeighable = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      unitOfMeasure: json['unitOfMeasure'] as String? ?? 'pcs',
      stockQuantity: double.parse(json['stockQuantity'].toString()),
      isWeighable: json['isWeighable'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'sku': sku,
      'barcode': barcode,
      'unitOfMeasure': unitOfMeasure,
      'stockQuantity': stockQuantity,
      'isWeighable': isWeighable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? sku,
    String? barcode,
    String? unitOfMeasure,
    double? stockQuantity,
    bool? isWeighable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isWeighable: isWeighable ?? this.isWeighable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

