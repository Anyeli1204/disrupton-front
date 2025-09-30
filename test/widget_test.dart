import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:disrupton_app/main.dart';
import 'package:disrupton_app/providers/auth_provider.dart';
import 'package:camera/camera.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Create a mock camera
    const mockCamera = CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(cameras: [mockCamera]),
      ),
    );

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}