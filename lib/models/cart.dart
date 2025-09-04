class CartItem {
  final String id;
  final String itemId;
  final String itemType; // 'product' or 'service'
  final String title;
  final String imageUrl;
  final double price;
  final String location;
  int quantity;
  final DateTime addedAt;
  final Map<String, dynamic> metadata;

  CartItem({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.location,
    this.quantity = 1,
    required this.addedAt,
    this.metadata = const {},
  });

  // Getters de utilidad
  bool get isProduct => itemType == 'product';
  bool get isService => itemType == 'service';
  double get totalPrice => price * quantity;
  String get formattedPrice => 'S/ ${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => 'S/ ${totalPrice.toStringAsFixed(2)}';

  // Métodos para modificar cantidad
  CartItem increaseQuantity() {
    return CartItem(
      id: id,
      itemId: itemId,
      itemType: itemType,
      title: title,
      imageUrl: imageUrl,
      price: price,
      location: location,
      quantity: quantity + 1,
      addedAt: addedAt,
      metadata: metadata,
    );
  }

  CartItem decreaseQuantity() {
    if (quantity <= 1) return this;
    return CartItem(
      id: id,
      itemId: itemId,
      itemType: itemType,
      title: title,
      imageUrl: imageUrl,
      price: price,
      location: location,
      quantity: quantity - 1,
      addedAt: addedAt,
      metadata: metadata,
    );
  }

  CartItem updateQuantity(int newQuantity) {
    if (newQuantity < 1) return this;
    return CartItem(
      id: id,
      itemId: itemId,
      itemType: itemType,
      title: title,
      imageUrl: imageUrl,
      price: price,
      location: location,
      quantity: newQuantity,
      addedAt: addedAt,
      metadata: metadata,
    );
  }

  // Conversión JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      itemId: json['itemId'] ?? '',
      itemType: json['itemType'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      quantity: json['quantity'] ?? 1,
      addedAt:
          DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemType': itemType,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'location': location,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;

  @override
  String toString() {
    return 'CartItem(id: $id, itemId: $itemId, title: $title, quantity: $quantity, price: $price)';
  }
}

// Modelo para el carrito completo
class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  // Getters calculados
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItems => items.length;
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get taxes => subtotal * 0.18; // IGV 18% en Perú
  double get total => subtotal + taxes;

  String get formattedSubtotal => 'S/ ${subtotal.toStringAsFixed(2)}';
  String get formattedTaxes => 'S/ ${taxes.toStringAsFixed(2)}';
  String get formattedTotal => 'S/ ${total.toStringAsFixed(2)}';

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  List<CartItem> get productItems =>
      items.where((item) => item.isProduct).toList();
  List<CartItem> get serviceItems =>
      items.where((item) => item.isService).toList();

  // Métodos de utilidad
  CartItem? findItem(String itemId) {
    try {
      return items.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      return null;
    }
  }

  bool hasItem(String itemId) => findItem(itemId) != null;

  int getItemQuantity(String itemId) {
    final item = findItem(itemId);
    return item?.quantity ?? 0;
  }

  // Conversión JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Cart(userId: $userId, items: ${items.length}, total: $formattedTotal)';
  }
}
