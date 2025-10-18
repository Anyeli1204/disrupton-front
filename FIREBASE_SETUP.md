# Firebase Setup - Disrupton Project

Guía completa de configuración de Firebase para el proyecto Disrupton, incluyendo Firestore, Firebase Storage y Firebase Authentication.

---

## Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Servicios de Firebase Utilizados](#servicios-de-firebase-utilizados)
3. [Prerequisitos](#prerequisitos)
4. [Configuración del Proyecto Firebase](#configuración-del-proyecto-firebase)
5. [Configuración del Backend (Spring Boot)](#configuración-del-backend-spring-boot)
6. [Configuración del Frontend (Flutter)](#configuración-del-frontend-flutter)
7. [Reglas de Seguridad](#reglas-de-seguridad)
8. [Estructura de Datos](#estructura-de-datos)
9. [Troubleshooting](#troubleshooting)

---

## Descripción General

El proyecto Disrupton utiliza Firebase como plataforma backend-as-a-service (BaaS) para:

- **Firestore Database**: Base de datos NoSQL para almacenar objetos culturales, usuarios, comentarios, etc.
- **Firebase Storage**: Almacenamiento de archivos (modelos 3D, imágenes, thumbnails)
- **Firebase Authentication**: Sistema de autenticación y autorización

**Arquitectura:**
```
┌─────────────────┐
│  Flutter App    │
│   (Frontend)    │
└────────┬────────┘
         │ HTTP API
         ▼
┌─────────────────┐
│  Spring Boot    │◄──────┐
│   (Backend)     │       │
└────────┬────────┘       │
         │                │
         │ Admin SDK      │ Service Account
         ▼                │
┌─────────────────┐       │
│    Firebase     │───────┘
│  - Firestore    │
│  - Storage      │
│  - Auth         │
└─────────────────┘
```

---

## Servicios de Firebase Utilizados

### 1. **Firestore Database**
- Colecciones: `cultural_objects`, `users`, `murals`, `comments`, etc.
- Modo: **Producción** con reglas de seguridad
- Región: `us-central1` (o la región configurada)

### 2. **Firebase Storage**
- Bucket: `disrupton-new.firebasestorage.app`
- Estructura de carpetas:
  ```
  ├── models/
  │   └── {userId}/
  │       └── {modelId}/
  │           └── models_*.glb
  ├── thumbnails/
  │   └── {userId}/
  │       └── {modelId}/
  │           └── thumbnails_*.jpg
  ├── comments/
  │   └── {userId}/
  │       └── {commentId}/
  │           └── comment_*.jpg
  └── processing/
      └── {userId}/
          └── {modelId}/
              └── processing_*.jpg
  ```

### 3. **Firebase Authentication**
- Proveedores habilitados: Email/Password
- Custom Claims para roles: `ADMIN`, `MODERATOR`, `USER`, `GUIDE`, `ARTISAN`, `AGENTE_CULTURAL`

---

## Prerequisitos

### Software Necesario

1. **Firebase CLI** (para deployment de reglas)
   ```bash
   npm install -g firebase-tools
   ```

2. **Java 17+** (para Spring Boot backend)

3. **Flutter 3.x+** (para la app móvil)

4. **Cuenta de Google Cloud Platform**
   - Acceso a Firebase Console
   - Permisos de administrador del proyecto

---

## Configuración del Proyecto Firebase

### Paso 1: Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o usa uno existente
3. Nombre del proyecto: `disrupton-new` (o el que prefieras)
4. Habilita Google Analytics (opcional)

### Paso 2: Habilitar Servicios

#### 2.1 Firestore Database
```bash
# Desde Firebase Console
1. Ir a "Firestore Database"
2. Clic en "Crear base de datos"
3. Seleccionar "Modo de producción"
4. Elegir región: us-central1 (recomendado)
```

#### 2.2 Firebase Storage
```bash
# Desde Firebase Console
1. Ir a "Storage"
2. Clic en "Comenzar"
3. Aceptar las reglas por defecto (las actualizaremos después)
4. Bucket creado: {project-id}.firebasestorage.app
```

#### 2.3 Firebase Authentication
```bash
# Desde Firebase Console
1. Ir a "Authentication"
2. Clic en "Comenzar"
3. Habilitar "Correo electrónico/contraseña"
4. Guardar configuración
```

### Paso 3: Generar Service Account Key (Para Backend)

**IMPORTANTE**: Este archivo contiene credenciales sensibles. **NUNCA** lo subas a Git.

```bash
# Desde Firebase Console
1. Ir a "Configuración del proyecto" (ícono de engranaje)
2. Pestaña "Cuentas de servicio"
3. Clic en "Generar nueva clave privada"
4. Se descargará un archivo JSON
```

**Estructura del archivo descargado:**
```json
{
  "type": "service_account",
  "project_id": "disrupton-new",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@disrupton-new.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

**Renombrar y mover el archivo:**
```bash
# Renombrar a firebase-service-account.json
# Mover a: disrupton-back/src/main/resources/
mv ~/Downloads/disrupton-new-xxxxx.json disrupton-back/src/main/resources/firebase-service-account.json

# Agregar al .gitignore (IMPORTANTE)
echo "firebase-service-account.json" >> disrupton-back/.gitignore
```

### Paso 4: Configurar App Android (Flutter)

```bash
# Desde Firebase Console
1. Ir a "Configuración del proyecto"
2. En "Tus aplicaciones", clic en ícono de Android
3. Llenar formulario:
   - Package name: com.example.disrupton (o tu package)
   - App nickname: Disrupton Android
   - SHA-1: (obtener con: cd android && ./gradlew signingReport)
4. Descargar google-services.json
5. Mover a: android/app/google-services.json
```

### Paso 5: Configurar App iOS (Flutter) - Opcional

```bash
# Desde Firebase Console
1. En "Tus aplicaciones", clic en ícono de iOS
2. Llenar formulario:
   - Bundle ID: com.example.disrupton (mismo que Android)
   - App nickname: Disrupton iOS
3. Descargar GoogleService-Info.plist
4. Agregar a Xcode en ios/Runner/
```

---

## Configuración del Backend (Spring Boot)

### Archivos de Configuración

#### 1. `application.yml`

Ubicación: `disrupton-back/src/main/resources/application.yml`

```yaml
# Configuración de Firebase
firebase:
  project:
    id: ${FIREBASE_PROJECT_ID:disrupton-new}
    storage:
      bucket: ${FIREBASE_STORAGE_BUCKET:disrupton-new.firebasestorage.app}
  service:
    account:
      file: ${FIREBASE_SERVICE_ACCOUNT_FILE:firebase-service-account.json}
```

**Variables de Entorno (opcional):**
```bash
# .env o variables del sistema
export FIREBASE_PROJECT_ID=disrupton-new
export FIREBASE_STORAGE_BUCKET=disrupton-new.firebasestorage.app
export FIREBASE_SERVICE_ACCOUNT_FILE=firebase-service-account.json
```

#### 2. `FirebaseConfig.java`

Ubicación: `disrupton-back/src/main/java/com/disrupton/config/FirebaseConfig.java`

Este archivo ya está configurado y realiza:
- Inicialización de Firebase Admin SDK
- Configuración de Storage Service con credenciales
- Carga automática del archivo de service account

**Flujo de inicialización:**
```
@PostConstruct
    ↓
Cargar firebase-service-account.json
    ↓
Crear FirebaseOptions con credenciales
    ↓
Inicializar FirebaseApp
    ↓
Crear Storage Bean
    ↓
✅ Firebase listo para usar
```

#### 3. Dependencias (pom.xml)

```xml
<!-- Firebase Admin SDK -->
<dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
    <version>9.4.2</version>
</dependency>

<!-- Google Cloud Storage -->
<dependency>
    <groupId>com.google.cloud</groupId>
    <artifactId>google-cloud-storage</artifactId>
    <version>2.42.0</version>
</dependency>

<!-- Google Cloud Firestore -->
<dependency>
    <groupId>com.google.cloud</groupId>
    <artifactId>google-cloud-firestore</artifactId>
    <version>3.25.2</version>
</dependency>
```

### Servicios Implementados

#### 1. **FirebaseStorageService.java**

Operaciones de Storage:
```java
// Subir modelo 3D
String uploadModel3D(MultipartFile file, String userId, String modelId)

// Subir thumbnail
String uploadThumbnail(MultipartFile file, String userId, String modelId)

// Subir imágenes para procesamiento
String uploadImagesForProcessing(MultipartFile[] files, String userId, String modelId)

// Eliminar archivo
boolean deleteFile(String filePath)

// Obtener URL pública
String getPublicUrl(String filePath)

// Verificar si existe archivo
boolean fileExists(String filePath)
```

**Ejemplo de uso:**
```java
@Autowired
private FirebaseStorageService storageService;

// Subir modelo
String modelUrl = storageService.uploadModel3D(file, userId, modelId);
// Resultado: https://storage.googleapis.com/disrupton-new.firebasestorage.app/models/...
```

#### 2. **CulturalObjectService.java**

Operaciones de Firestore para objetos culturales:
```java
// Obtener todos los objetos
List<CulturalObjectDto> getAllObjects()

// Obtener por ID
CulturalObjectDto getObjectById(String objectId)

// Crear objeto
CulturalObjectDto createObject(CulturalObjectRequest request)

// Actualizar objeto
CulturalObjectDto updateObject(String objectId, CulturalObjectRequest request)

// Eliminar objeto
boolean deleteObject(String objectId)

// Búsqueda y filtros
List<CulturalObjectDto> getObjectsByType(String culturalType)
List<CulturalObjectDto> getObjectsByRegion(String region)
List<CulturalObjectDto> searchObjects(String query)
```

---

## Configuración del Frontend (Flutter)

### Paso 1: Instalar Firebase CLI Tools

```bash
# En la raíz del proyecto Flutter
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add firebase_storage
flutter pub add cloud_firestore

# Configurar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para Flutter
flutterfire configure
```

### Paso 2: Inicializar Firebase en Flutter

#### `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### Paso 3: Configuración de Servicios

#### `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  firebase_storage: ^12.3.4
  cloud_firestore: ^5.5.2

  # HTTP para llamadas al backend
  http: ^1.2.2
```

### Arquitectura de Comunicación

**IMPORTANTE**: La app Flutter **NO accede directamente a Firebase**. Todo pasa por el backend Spring Boot.

```
┌────────────────────┐
│   Flutter App      │
└─────────┬──────────┘
          │
          │ HTTP REST API
          ▼
┌────────────────────┐
│  Spring Boot API   │
│  - /api/cultural-  │
│    objects         │
│  - /api/firebase/  │
│    storage         │
└─────────┬──────────┘
          │
          │ Firebase Admin SDK
          ▼
┌────────────────────┐
│     Firebase       │
│  - Firestore       │
│  - Storage         │
└────────────────────┘
```

**Ejemplo de comunicación:**

```dart
// Flutter Service
class CulturalObjectService {
  final String baseUrl = 'https://your-backend.com';

  // Subir modelo 3D
  Future<Map<String, dynamic>> uploadModel(File file, String userId, String modelId) async {
    var uri = Uri.parse('$baseUrl/api/firebase/storage/upload-model');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['userId'] = userId;
    request.fields['modelId'] = modelId;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return json.decode(responseBody);
  }

  // Obtener objetos culturales
  Future<List<CulturalObject>> getAllObjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/cultural-objects'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CulturalObject.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load objects');
    }
  }
}
```

---

## Reglas de Seguridad

### Firestore Rules

Ubicación: `disrupton-back/firestore.rules`

**Características principales:**
- Autenticación obligatoria para todas las operaciones
- Control de acceso basado en roles (RBAC)
- Los usuarios solo pueden modificar sus propios datos
- Moderadores y Admins tienen permisos elevados

**Estructura de roles:**
```javascript
// Roles disponibles en custom claims
- USER: Usuario básico
- MODERATOR: Moderador de contenido
- ADMIN: Administrador completo
- GUIDE: Guía turístico
- ARTISAN: Artesano
- AGENTE_CULTURAL: Agente cultural
```

**Ejemplo de reglas para objetos culturales:**
```javascript
match /cultural_objects/{objectId} {
  // Leer: Usuarios autenticados pueden ver objetos aprobados
  allow read: if request.auth != null &&
    (resource.data.status == 'approved' ||
     request.auth.token.role == 'MODERATOR' ||
     request.auth.token.role == 'ADMIN');

  // Crear: Cualquier usuario autenticado
  allow create: if request.auth != null;

  // Actualizar: Solo creador, moderadores o admins
  allow update: if request.auth != null &&
    (request.auth.uid == resource.data.createdBy ||
     request.auth.token.role == 'MODERATOR' ||
     request.auth.token.role == 'ADMIN');

  // Eliminar: Solo moderadores y admins
  allow delete: if request.auth != null &&
    (request.auth.token.role == 'MODERATOR' ||
     request.auth.token.role == 'ADMIN');
}
```

### Deployment de Reglas

```bash
# Login a Firebase
firebase login

# Inicializar proyecto (primera vez)
cd disrupton-back
firebase init firestore

# Deploy de reglas
firebase deploy --only firestore:rules

# Verificar reglas en Firebase Console
# → Firestore Database → Rules
```

### Storage Rules (Configuración Manual)

Desde Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir lectura pública (ya que usamos URLs públicas)
    match /{allPaths=**} {
      allow read: if true;
      allow write: if false; // Solo el backend puede escribir
    }
  }
}
```

**Explicación:**
- `allow read: if true` → Cualquiera puede descargar archivos (URLs públicas)
- `allow write: if false` → Solo el backend con Service Account puede subir archivos
- Esto previene que usuarios maliciosos suban archivos directamente

---

## Estructura de Datos

### Colección: `cultural_objects`

```javascript
{
  objectId: string,           // UUID generado automáticamente
  name: string,               // Nombre del objeto
  description: string,        // Descripción detallada
  culturalType: string,       // Tipo: "Arquitectura", "Escultura", etc.
  theme: string,              // Tema: "Religioso", "Ceremonial", etc.
  culture: string,            // Cultura: "Inca", "Maya", etc.
  period: string,             // Período: "Siglo XVI", "Precolombino", etc.
  region: string,             // Región: "Cusco, Perú"
  latitude: number,           // Coordenada geográfica
  longitude: number,          // Coordenada geográfica
  imageUrl: string,           // URL de imagen principal
  model3dUrl: string,         // URL del modelo 3D (.glb)
  audioUrl: string,           // URL de audio guía
  videoUrl: string,           // URL de video
  additionalInfo: string,     // Información adicional
  isActive: boolean,          // Si está activo
  createdAt: timestamp,       // Fecha de creación
  updatedAt: timestamp        // Última actualización
}
```

**Ejemplo de documento:**
```json
{
  "objectId": "603b26a6-427f-48fd-9650-6b6084932514",
  "name": "Vasija Ceremonial Inca",
  "description": "Vasija utilizada en ceremonias religiosas del Imperio Inca durante el siglo XV",
  "culturalType": "Cerámica",
  "theme": "Ceremonial",
  "culture": "Inca",
  "period": "Siglo XV",
  "region": "Cusco, Perú",
  "latitude": -13.5319,
  "longitude": -71.9675,
  "imageUrl": "https://storage.googleapis.com/.../thumbnail.jpg",
  "model3dUrl": "https://storage.googleapis.com/disrupton-new.firebasestorage.app/models/EzGRz.../model.glb",
  "audioUrl": null,
  "videoUrl": null,
  "additionalInfo": "Encontrada en excavaciones de 2020",
  "isActive": true,
  "createdAt": {
    "_seconds": 1713456789,
    "_nanoseconds": 123456000
  },
  "updatedAt": {
    "_seconds": 1713456789,
    "_nanoseconds": 123456000
  }
}
```

### Colección: `users`

```javascript
{
  userId: string,             // Firebase Auth UID
  email: string,              // Email del usuario
  name: string,               // Nombre completo
  role: string,               // Rol: USER, ADMIN, MODERATOR, etc.
  isActive: boolean,          // Si está activo
  createdAt: timestamp,       // Fecha de registro
  updatedAt: timestamp        // Última actualización
}
```

---

## Troubleshooting

### Error: "The caller does not have permission"

**Problema:** El backend no puede acceder a Firebase.

**Solución:**
```bash
# Verificar que el archivo existe
ls disrupton-back/src/main/resources/firebase-service-account.json

# Verificar que el proyecto ID es correcto
cat disrupton-back/src/main/resources/application.yml | grep firebase

# Verificar permisos del Service Account en GCP Console
# → IAM & Admin → Service Accounts
# Debe tener roles: Firebase Admin, Storage Admin
```

### Error: "Firebase app not initialized"

**Problema:** Firebase no se inicializó correctamente en Flutter.

**Solución:**
```dart
// En main.dart, asegurar que está antes de runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### Error: "CORS policy blocked"

**Problema:** Peticiones desde Flutter a backend bloqueadas por CORS.

**Solución:**
El backend ya tiene CORS configurado en `SecurityConfig.java`. Verificar:
```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    configuration.setAllowedOrigins(List.of("*")); // ✅ Permite todos
    configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(List.of("*"));
    return source;
}
```

### URLs de modelos 3D expiran

**Problema:** Las URLs de Storage dejan de funcionar después de un tiempo.

**Solución:**
Ya implementado en `FirebaseStorageService.java`:
```java
// ✅ Usar URLs públicas permanentes
String downloadUrl = String.format(
    "https://storage.googleapis.com/%s/%s",
    bucketName,
    filePath
);

// ❌ NO usar signed URLs (expiran)
// String downloadUrl = blob.getMediaLink(); // MAL
```

### Error: "Storage bucket not found"

**Problema:** El bucket de Storage no existe o tiene nombre incorrecto.

**Solución:**
```bash
# Verificar en application.yml
firebase.project.storage.bucket: disrupton-new.firebasestorage.app

# Verificar en Firebase Console → Storage
# El bucket debe existir y tener este nombre exacto
```

### No se pueden subir archivos grandes

**Problema:** Archivos > 50MB fallan.

**Solución:**
```yaml
# En application.yml
spring:
  servlet:
    multipart:
      max-file-size: 50MB      # ← Ajustar según necesidad
      max-request-size: 500MB  # ← Total de la request
```

---

## Comandos Útiles

### Firebase CLI

```bash
# Login
firebase login

# Ver proyectos
firebase projects:list

# Seleccionar proyecto
firebase use disrupton-new

# Deploy reglas de Firestore
firebase deploy --only firestore:rules

# Ver logs en tiempo real
firebase firestore:logs

# Emuladores locales (desarrollo)
firebase emulators:start
```

### FlutterFire CLI

```bash
# Configurar Firebase en Flutter
flutterfire configure

# Listar apps configuradas
flutterfire list

# Agregar nueva plataforma
flutterfire configure --platforms=android,ios
```

### Testing

```bash
# Test de conexión a Firestore (desde backend)
# Crear un endpoint de test en Spring Boot:

@GetMapping("/test-firebase")
public String testFirebase() {
    try {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection("test").document("test-doc");
        docRef.set(Map.of("test", "success")).get();
        return "✅ Firebase connection OK";
    } catch (Exception e) {
        return "❌ Error: " + e.getMessage();
    }
}
```

---

## Recursos Adicionales

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Admin SDK - Java](https://firebase.google.com/docs/admin/setup)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Storage for Firebase](https://firebase.google.com/docs/storage)

---

## Contacto y Soporte

Para dudas sobre la configuración de Firebase en este proyecto:

1. Revisar este README primero
2. Verificar logs del backend: `disrupton-back/logs/`
3. Consultar Firebase Console para ver errores
4. Revisar documentación oficial de Firebase

---

**Última actualización:** Octubre 2025
**Versión:** 1.0
**Proyecto:** Disrupton - Cultural Heritage Platform
