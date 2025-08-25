import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductListTile extends StatelessWidget {
  final Product product;

  const ProductListTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            )
          : Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.image),
            ),
      title: Text(
        product.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.description),
          SizedBox(height: 4),
          Text('Price: \$${product.price.toStringAsFixed(2)}'),
          SizedBox(height: 4),
          Text('Agent: ${product.culturalAgentName}'),
        ],
      ),
      // Add onTap for potential product details screen navigation later
      onTap: () {
        // TODO: Implement navigation to product details screen if needed
        print('Tapped on product: ${product.name}');
      },
    );
  }
}