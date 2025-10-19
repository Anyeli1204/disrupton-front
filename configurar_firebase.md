# Configuración Rápida de Firebase - 3 Comandos

## ⚡ Configuración Rápida (Recomendado)

Si tienes Flutter y Dart instalados, estos 3 comandos lo configuran todo:

```bash
# 1. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configurar Firebase (te pedirá login y selección de proyecto)
flutterfire configure

# 3. Limpiar y ejecutar
flutter clean && flutter pub get && flutter run
```

Eso es todo! La app ahora usará Firebase Auth en lugar del backend.

---

## 📋 Checklist Rápido

Antes de ejecutar los comandos, asegúrate de:

- [ ] Tener una cuenta de Google
- [ ] Tener acceso a [Firebase Console](https://console.firebase.google.com/)
- [ ] Tener Flutter instalado
- [ ] Tener conexión a internet

---

## 🎯 Qué hace cada comando

### 1. `dart pub global activate flutterfire_cli`
Instala la herramienta FlutterFire CLI que automatiza la configuración de Firebase.

### 2. `flutterfire configure`
- Te pedirá login con tu cuenta de Google
- Mostrará tus proyectos de Firebase (o te permitirá crear uno nuevo)
- Selecciona o crea el proyecto "Disrupton"
- Selecciona las plataformas (Android, iOS, Web)
- Genera automáticamente:
  - `lib/firebase_options.dart` con la configuración correcta
  - Actualiza configuraciones de Android/iOS

### 3. `flutter clean && flutter pub get && flutter run`
- Limpia builds anteriores
- Descarga dependencias
- Ejecuta la app

---

## 🎨 Qué Verás en la App

Después de ejecutar, verás la pantalla de login con:

```
┌─────────────────────────────────┐
│                                 │
│         [Logo Minkar]           │
│                                 │
│   Explora la cultura con RA     │
│                                 │
│     ┌───────────────────────┐   │
│     │  Iniciar Sesión       │   │
│     ├───────────────────────┤   │
│     │  Email:               │   │
│     │  [________________]   │   │
│     │  Contraseña:          │   │
│     │  [________________]   │   │
│     │                       │   │
│     │  [Iniciar Sesión]     │   │
│     │                       │   │
│     │  ────── o ──────      │   │
│     │                       │   │
│     │  [🔵 Continuar con    │   │  ← NUEVO!
│     │      Google]          │   │
│     │                       │   │
│     │  ¿No tienes cuenta?   │   │
│     │  Regístrate          │   │
│     └───────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

---

## 🔧 Si `flutterfire configure` No Está Disponible

Si el comando `flutterfire configure` no funciona, aquí está el método manual:

### Manual: Paso a Paso

#### 1. Crear Proyecto en Firebase Console

1. Ve a https://console.firebase.google.com/
2. Clic en "Add project"
3. Nombre: **Disrupton**
4. Clic en "Create project"

#### 2. Habilitar Authentication

1. En el menú lateral, ve a **Build** > **Authentication**
2. Clic en **Get Started**
3. Habilita:
   - **Email/Password**: Enable → Save
   - **Google**: Enable → Ingresa email de soporte → Save

#### 3. Registrar App Android

1. En **Project Settings** (ícono engranaje)
2. Clic en el ícono de Android
3. Package name: `com.example.disrupton_app`
4. Nickname: Disrupton
5. SHA-1: Ejecuta `cd android && ./gradlew signingReport` y copia el SHA-1
6. Clic en **Register app**
7. Descarga `google-services.json` → `android/app/google-services.json`

#### 4. Actualizar android/build.gradle

Agrega en `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.2'
```

#### 5. Actualizar android/app/build.gradle

Al final del archivo:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 6. Actualizar lib/firebase_options.dart

Copia los valores de Firebase Console > Project Settings > Your apps > Config

---

## 🚀 Probar la App

Una vez configurado, prueba:

### Test 1: Registro con Email
1. Abre la app
2. Tap en "Regístrate"
3. Completa el formulario
4. Verifica que se cree el usuario en Firebase Console > Authentication

### Test 2: Login con Google
1. Abre la app
2. Tap en "Continuar con Google"
3. Selecciona tu cuenta de Google
4. Verifica que entres a la app

### Test 3: Cerrar Sesión
1. Ve a la pantalla de Cuenta
2. Tap en "Cerrar sesión"
3. Verifica que vuelvas a la pantalla de login

---

## 📊 Comparación: Antes vs Ahora

### Antes (Backend JWT)
```
Usuario → LoginScreen → Backend API → JWT Token → App
                         ↓
                   Base de Datos
```

### Ahora (Firebase Auth)
```
Usuario → AuthScreen → Firebase Auth → Token automático → App
             ↓                ↓
      Google Sign-In    Firebase Console
```

**Ventajas:**
- ✅ No necesitas backend para autenticación
- ✅ Google Sign-In incluido
- ✅ Recuperar contraseña automático
- ✅ Tokens se refrescan automáticamente
- ✅ Gratis hasta 10,000 usuarios/mes

---

## 🆘 Solución de Problemas

### Error: "firebase_options.dart not found"
**Solución:** Ejecuta `flutterfire configure`

### Error: "MISSING_CLIENT_ID" en Google Sign-In
**Solución:**
1. Verifica que hayas agregado el SHA-1 en Firebase Console
2. Descarga de nuevo `google-services.json` DESPUÉS de agregar SHA-1
3. Ejecuta `flutter clean && flutter run`

### Error: "Default FirebaseApp is not initialized"
**Solución:** Verifica que `main.dart` tenga:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### La app compila pero no aparece el botón de Google
**Solución:** Verifica que estés usando `AuthScreen` y no `LoginScreen`

---

## 📞 Ayuda Adicional

- 📄 **Guía completa:** `FIREBASE_SETUP_INSTRUCTIONS.md`
- 📄 **Resumen:** `FIREBASE_MIGRATION_SUMMARY.md`
- 📄 **Pasos detallados:** `PASOS_SIGUIENTES.md`

---

## ✅ Checklist Final

- [ ] Ejecuté `dart pub global activate flutterfire_cli`
- [ ] Ejecuté `flutterfire configure` y seleccioné mi proyecto
- [ ] Ejecuté `flutter clean && flutter pub get`
- [ ] La app compila sin errores
- [ ] Veo la pantalla AuthScreen con el botón de Google
- [ ] Puedo registrarme con email/password
- [ ] Puedo iniciar sesión con Google
- [ ] Los usuarios aparecen en Firebase Console > Authentication

---

**¡Listo!** Ahora tu app usa Firebase Auth en lugar del backend. 🎉
