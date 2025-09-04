class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'product' o 'service'
  final String title;
  final String imageUrl;
  final double price;
  final String location;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      itemType: json['itemType'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isProduct => itemType == 'product';
  bool get isService => itemType == 'service';

  String get formattedPrice => 'S/ ${price.toStringAsFixed(2)}';
}
