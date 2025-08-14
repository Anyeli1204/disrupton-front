import 'package:flutter/material.dart';
import 'lib/routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disruptón - Realidad Aumentada Cultural',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/onboarding',
      routes: AppRoutes.routes,
    );
  }
}
