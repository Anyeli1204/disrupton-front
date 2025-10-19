# Pasos Siguientes para Configurar Firebase

## Estado Actual

✅ **Código Actualizado:**
- `main.dart` ahora usa Firebase Auth en lugar del backend
- `SplashScreen` actualizado para usar `FirebaseAuthProvider`
- `AuthScreen` creado con botón de Google Sign-In
- `AccountScreen` actualizado con logout y delete account
- Dependencias instaladas

⚠️ **Falta Configurar:**
- Proyecto de Firebase Console
- Archivos de configuración de Firebase

## Pasos para Completar la Configuración

### Paso 1: Crear Proyecto en Firebase Console (5 minutos)

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Clic en "Add project" (Agregar proyecto)
3. Nombre del proyecto: **Disrupton** (o el que prefieras)
4. Desactiva Google Analytics si no lo necesitas (opcional)
5. Clic en "Create project"

### Paso 2: Habilitar Autenticación (2 minutos)

1. En tu proyecto, ve a **Build** > **Authentication**
2. Clic en **Get Started**
3. En la pestaña **Sign-in method**:
   - Habilita **Email/Password** → Clic en Enable → Save
   - Habilita **Google** → Clic en Enable → Ingresa un email de soporte → Save

### Paso 3: Configurar App Android (10 minutos)

#### 3.1 Obtener el SHA-1

Abre una terminal en la raíz del proyecto y ejecuta:

```bash
cd android
./gradlew signingReport
```

En Windows:
```bash
cd android
gradlew.bat signingReport
```

Copia el **SHA-1** que aparece bajo "Task :app:signingReport" (ej: `AA:BB:CC:DD:...`)

#### 3.2 Registrar la App Android

1. En Firebase Console, ve a **Project Settings** (ícono de engranaje arriba)
2. En la sección "Your apps", clic en el ícono de Android
3. Registra la app:
   - **Android package name**: `com.example.disrupton_app`
   - **App nickname**: Disrupton (opcional)
   - **Debug signing certificate SHA-1**: Pega el SHA-1 que copiaste
4. Clic en **Register app**

#### 3.3 Descargar google-services.json

1. Descarga el archivo `google-services.json`
2. Colócalo en: `android/app/google-services.json`

#### 3.4 Actualizar build.gradle

**Archivo: `android/build.gradle`**

Busca la sección `buildscript { dependencies { ... } }` y agrega:

```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Agregar esta línea:
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

**Archivo: `android/app/build.gradle`**

Al final del archivo, después de todas las secciones, agrega:

```gradle
apply plugin: 'com.google.gms.google-services'
```

También verifica que `minSdkVersion` sea al menos 21:

```gradle
defaultConfig {
    minSdkVersion 21  // Debe ser 21 o mayor
}
```

### Paso 4: Generar firebase_options.dart (IMPORTANTE)

Ejecuta este comando en la raíz del proyecto:

```bash
# Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

Esto te pedirá:
1. Seleccionar el proyecto de Firebase (selecciona "Disrupton" o el nombre que pusiste)
2. Seleccionar las plataformas (Android, iOS, Web)
3. Generará automáticamente `lib/firebase_options.dart` con la configuración correcta

**Importante:** Esto reemplazará el archivo temporal que creé.

### Paso 5: Limpiar y Ejecutar

```bash
# Limpiar builds anteriores
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

## Verificar que Funciona

1. La app debería iniciar sin errores
2. Deberías ver la pantalla de `AuthScreen` con:
   - Campo de email
   - Campo de contraseña
   - Botón "Iniciar Sesión"
   - **Botón "Continuar con Google"** con el logo de Google
3. Intenta registrarte con email y contraseña
4. Intenta iniciar sesión con Google

## Solución de Problemas Comunes

### Error: "Default FirebaseApp is not initialized"

**Solución:** Verifica que `flutterfire configure` haya generado correctamente el archivo `firebase_options.dart`

### Error: "MISSING_CLIENT_ID"

**Solución:**
1. Verifica que el SHA-1 esté correctamente configurado en Firebase Console
2. Descarga de nuevo el `google-services.json` DESPUÉS de agregar el SHA-1
3. Ejecuta `flutter clean && flutter run`

### Error al compilar: "google-services.json missing"

**Solución:** Verifica que el archivo esté en `android/app/google-services.json`

### El botón de Google no funciona

**Solución:**
1. Verifica que Google Sign-In esté habilitado en Firebase Console
2. Verifica que el SHA-1 sea correcto
3. Descarga de nuevo `google-services.json`

## Estructura de Archivos Final

```
disrupton-front/
├── lib/
│   ├── main.dart (✅ Actualizado para Firebase)
│   ├── firebase_options.dart (⚠️ Generar con flutterfire configure)
│   ├── providers/
│   │   └── firebase_auth_provider.dart (✅ Creado)
│   ├── services/
│   │   └── firebase_auth_service.dart (✅ Creado)
│   └── screens/
│       ├── auth_screen.dart (✅ Creado - con botón de Google)
│       ├── account_screen.dart (✅ Actualizado)
│       └── splash_screen.dart (✅ Actualizado)
├── android/
│   ├── app/
│   │   ├── google-services.json (⚠️ Descargar de Firebase)
│   │   └── build.gradle (⚠️ Agregar plugin de Google Services)
│   └── build.gradle (⚠️ Agregar classpath)
└── assets/
    └── images/
        └── logo_google.jpeg (✅ Ya existe)
```

## Comandos Rápidos

```bash
# 1. Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# 2. Configurar Firebase
flutterfire configure

# 3. Limpiar y ejecutar
flutter clean && flutter pub get && flutter run
```

## Comparación: Antes vs Ahora

| Aspecto | Antes (Backend) | Ahora (Firebase) |
|---------|----------------|------------------|
| Login | Backend JWT | Firebase Auth |
| Pantalla | LoginScreen | AuthScreen |
| Provider | AuthProvider | FirebaseAuthProvider |
| Google Sign-In | ❌ No | ✅ Sí (con logo) |
| Backend necesario | ✅ Sí | ❌ No |

## Notas Importantes

1. **El archivo `main_backend.dart` es un respaldo** de la versión anterior con backend
2. Si quieres volver al sistema anterior: `cp lib/main_backend.dart lib/main.dart`
3. El logo de Google ya está en `assets/images/logo_google.jpeg`
4. Firebase Auth funciona sin necesidad de backend
5. Los usuarios se crearán directamente en Firebase Console

## Siguiente Paso

**EJECUTA:** `flutterfire configure` para generar la configuración correcta de Firebase.

---

¿Necesitas ayuda? Consulta `FIREBASE_SETUP_INSTRUCTIONS.md` para más detalles.
