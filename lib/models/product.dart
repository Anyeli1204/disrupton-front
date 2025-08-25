class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String culturalAgentName;
  final String modelUrl;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.culturalAgentName,
    required this.modelUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Product',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? 'No description available.',
      culturalAgentName: json['culturalAgentName'] ?? 'Unknown Agent',
      modelUrl: json['modelUrl'] ?? '',
    );
  }
}