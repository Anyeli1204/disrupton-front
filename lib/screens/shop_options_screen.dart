import 'package:flutter/material.dart';
import '../screens/cultural_agents_list_screen.dart';
import '../screens/products_list_screen.dart';

class ShopOptionsScreen extends StatelessWidget { 
  const ShopOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CulturalAgentsListScreen()));
              },
              child: const Text('Ver contactos'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductsListScreen()));
              },
              child: const Text('Ver productos'),
            ),
          ],
        ),
      ),
    );
  }
}