import 'product.dart';

class CartItem {
  final Product product;
  double quantity;
  double? weight; // For weighable items

  CartItem({
    required this.product,
    this.quantity = 1,
    this.weight,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? weight,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
    );
  }
}

