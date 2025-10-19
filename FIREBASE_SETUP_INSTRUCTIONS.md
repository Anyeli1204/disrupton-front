# Instrucciones de Configuración de Firebase Auth

## Resumen de Implementación

Se ha implementado la autenticación con Firebase directamente desde el frontend de Flutter. Esta guía te ayudará a completar la configuración.

## Archivos Creados/Modificados

### Nuevos Archivos
1. `lib/services/firebase_auth_service.dart` - Servicio de autenticación con Firebase
2. `lib/providers/firebase_auth_provider.dart` - Provider para manejo de estado de autenticación
3. `lib/screens/auth_screen.dart` - Pantalla de login con email/password y Google Sign-In
4. `lib/screens/account_screen.dart` - Pantalla de cuenta con funcionalidad de logout y eliminar cuenta
5. `lib/main_firebase.dart` - Main.dart actualizado para usar Firebase
6. `lib/screens/splash_screen_firebase.dart` - SplashScreen actualizado

### Archivos Modificados
1. `pubspec.yaml` - Agregadas dependencias de Firebase

## Pasos de Configuración

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Nombra tu proyecto (ej: "Disrupton App")

### 2. Configurar Autenticación en Firebase

1. En Firebase Console, ve a **Authentication** en el menú lateral
2. Haz clic en **Get Started**
3. En la pestaña **Sign-in method**, habilita:
   - **Email/Password**: Habilita esta opción
   - **Google**: Habilita esta opción y configura el email de soporte

### 3. Configurar Android

#### 3.1. Descargar google-services.json

1. En Firebase Console, ve a **Project Settings** (ícono de engranaje)
2. En la sección **Your apps**, haz clic en **Add app** → **Android**
3. Registra la app con:
   - **Android package name**: `com.example.disrupton_app` (o el que uses en tu AndroidManifest.xml)
   - **App nickname**: Disrupton App (opcional)
   - **Debug signing certificate SHA-1**: Obtén ejecutando:
     ```bash
     cd android
     ./gradlew signingReport
     ```
     O en Windows:
     ```bash
     cd android
     gradlew.bat signingReport
     ```
     Copia el SHA-1 que aparece bajo "Task :app:signingReport"

4. Descarga el archivo `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`

#### 3.2. Configurar build.gradle

**archivo: `android/build.gradle`**
```gradle
buildscript {
    dependencies {
        // Agregar esta línea
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

**archivo: `android/app/build.gradle`**
```gradle
// Al final del archivo, después de dependencies
apply plugin: 'com.google.gms.google-services'

// Dentro de android { defaultConfig { ... } }
defaultConfig {
    minSdkVersion 21  // Firebase requiere mínimo API 21
}
```

### 4. Configurar iOS (Si desarrollas para iOS)

#### 4.1. Descargar GoogleService-Info.plist

1. En Firebase Console, ve a **Project Settings**
2. En la sección **Your apps**, haz clic en **Add app** → **iOS**
3. Registra la app con:
   - **iOS bundle ID**: `com.example.disruptonApp` (verifica en ios/Runner.xcodeproj)
   - **App nickname**: Disrupton App (opcional)

4. Descarga el archivo `GoogleService-Info.plist`
5. Abre el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en Xcode
   - Asegúrate de marcar "Copy items if needed"
   - Asegúrate de seleccionar el target "Runner"

#### 4.2. Configurar Info.plist para Google Sign-In

**archivo: `ios/Runner/Info.plist`**

Agrega esto dentro del dict principal:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplaza con tu REVERSED_CLIENT_ID del GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

Encuentra el `REVERSED_CLIENT_ID` en tu archivo `GoogleService-Info.plist`.

### 5. Instalar Dependencias

```bash
flutter pub get
```

### 6. Actualizar el Punto de Entrada

**Opción A: Reemplazar main.dart (Recomendado)**

Renombra el archivo actual:
```bash
mv lib/main.dart lib/main_old.dart
mv lib/main_firebase.dart lib/main.dart
```

**Opción B: Modificar main.dart manualmente**

Edita `lib/main.dart` para que se vea así:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'providers/firebase_auth_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/agentes_culturales_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/splash_screen_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FirebaseAuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => CollectionProvider()),
        ChangeNotifierProvider(create: (context) => AgentesCulturalesProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Disrupton App - Cultura Peruana AR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
```

También actualiza la importación en `splash_screen.dart`:
- Cambia `import '../providers/auth_provider.dart';`
- Por `import '../providers/firebase_auth_provider.dart';`
- Cambia `Provider.of<AuthProvider>` por `Provider.of<FirebaseAuthProvider>`

O usa el archivo `splash_screen_firebase.dart` ya creado.

### 7. Actualizar RegisterScreen (Opcional)

Si quieres que el RegisterScreen también use Firebase Auth, actualízalo para usar `FirebaseAuthProvider` en lugar de `AuthProvider`.

### 8. Probar la Aplicación

```bash
# Limpiar builds anteriores
flutter clean

# Obtener dependencias
flutter pub get

# Para Android
flutter run

# Para iOS
cd ios
pod install
cd ..
flutter run
```

## Uso de los Nuevos Componentes

### Pantalla de Autenticación (AuthScreen)

La nueva `AuthScreen` incluye:
- Inicio de sesión con email y contraseña
- Botón de Google Sign-In con logo personalizado
- Recuperación de contraseña
- Navegación a registro

### Pantalla de Cuenta (AccountScreen)

La nueva `AccountScreen` incluye:
- Información del usuario (foto, nombre, email)
- Botón para cerrar sesión
- Botón para eliminar cuenta (con re-autenticación)

### Provider de Autenticación (FirebaseAuthProvider)

Métodos disponibles:
- `signInWithEmailAndPassword()` - Login con email/password
- `registerWithEmailAndPassword()` - Registro con email/password
- `signInWithGoogle()` - Login con Google
- `signOut()` - Cerrar sesión
- `deleteAccount()` - Eliminar cuenta
- `sendPasswordResetEmail()` - Recuperar contraseña
- `getAuthHeaders()` - Obtener headers con token de Firebase

## Solución de Problemas

### Error: "Default FirebaseApp is not initialized"

Asegúrate de que:
1. Firebase.initializeApp() se llame en main() antes de runApp()
2. Los archivos google-services.json (Android) y GoogleService-Info.plist (iOS) estén correctamente ubicados

### Error: "MissingPluginException"

Ejecuta:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Google Sign-In no funciona

1. Verifica que el SHA-1 esté correctamente configurado en Firebase Console
2. Asegúrate de haber descargado el `google-services.json` DESPUÉS de agregar el SHA-1
3. Verifica que Google Sign-In esté habilitado en Firebase Console > Authentication > Sign-in method

### Error al compilar para iOS

1. Asegúrate de ejecutar `pod install` en el directorio ios:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. Abre el proyecto en Xcode y verifica que `GoogleService-Info.plist` esté en el target Runner

## Migración desde Backend Auth

Si quieres mantener compatibilidad con el sistema anterior:

1. Mantén ambos providers (AuthProvider y FirebaseAuthProvider)
2. Usa un flag de configuración para elegir qué sistema usar
3. Implementa un adaptador que unifique ambas interfaces

## Características Implementadas

✅ Autenticación con email y contraseña
✅ Autenticación con Google
✅ Cerrar sesión
✅ Eliminar cuenta
✅ Recuperar contraseña
✅ Verificación de email
✅ Re-autenticación para operaciones sensibles
✅ Manejo de errores con mensajes amigables
✅ Persistencia de sesión
✅ Logo de Google personalizado

## Próximos Pasos

1. Configurar Firebase en Firebase Console
2. Descargar archivos de configuración (google-services.json y GoogleService-Info.plist)
3. Actualizar build.gradle y Info.plist
4. Probar autenticación con email/password
5. Probar autenticación con Google
6. Probar funcionalidades de cuenta (logout, delete)

## Notas Importantes

- El logo de Google ya está en `assets/images/logo_google.jpeg`
- Firebase Auth maneja automáticamente la persistencia de sesión
- Los tokens de Firebase se refrescan automáticamente
- El sistema de roles se mantiene usando SharedPreferences
- Compatible con el flujo de permisos y selección de roles existente

## Contacto

Si necesitas ayuda adicional, consulta la documentación oficial:
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Firebase Auth Flutter](https://firebase.google.com/docs/auth/flutter/start)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
