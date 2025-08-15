# disrupton_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Compilar y Probar en Android

1. Instala [Android Studio](https://developer.android.com/studio).
2. Conecta un dispositivo Android o usa un emulador.
3. Ejecuta:
   ```bash
   flutter pub get
   flutter run
   ```
4. Para generar un APK:
   ```bash
   flutter build apk --release
   ```
5. El APK estará en `build/app/outputs/flutter-apk/app-release.apk`.

**Nota:**  
- Verifica permisos de cámara y ubicación en el dispositivo.
- ARCore es necesario para funciones de realidad aumentada (la mayoría de dispositivos modernos lo soportan).
