# 🚀 Motor de Realidad Aumentada - Disruptón

## 📋 Descripción

El motor de realidad aumentada permite detectar superficies físicas a través de la cámara del dispositivo y superponer objetos virtuales en 3D, permitiendo su manipulación en el espacio real.

## 🏗️ Estructura del Motor

```
📁 /lib
├── 📁 screens
│   └── ar_view_screen.dart        → Pantalla principal de RA
├── 📁 services
│   └── pieza_service.dart         → Servicio para obtener modelos 3D
├── 📁 models
│   └── pieza.dart                 → Modelo de datos de piezas
├── 📁 providers
│   └── ar_provider.dart           → Manejo de estado AR
├── 📁 utils
│   ├── model_loader.dart          → Cargador de modelos 3D
│   └── ar_config.dart             → Configuración del motor
└── 📁 assets
    ├── 📁 models/                 → Modelos 3D locales
    └── 📁 images/                 → Texturas y recursos
```

## 🔧 Características Principales

### ✅ Funcionalidades Implementadas

- **Detección de Planos**: Detección automática de superficies
- **Carga de Modelos 3D**: Soporte para archivos .glb y .gltf
- **Caché Inteligente**: Almacenamiento local de modelos
- **Gestos Interactivos**: Rotación, escalado y traslación
- **Información Contextual**: Panel de información de piezas
- **Manejo de Estado**: Provider para gestión de estado AR

### 🎯 Características Avanzadas

- **Pre-carga de Modelos**: Carga anticipada para mejor rendimiento
- **Verificación de Disponibilidad**: Comprobación de URLs de modelos
- **Metadatos de Modelos**: Información adicional de archivos 3D
- **Configuración Flexible**: Parámetros ajustables por plataforma
- **Manejo de Errores**: Sistema robusto de manejo de errores

## 🛠️ Configuración

### Dependencias Requeridas

```yaml
dependencies:
  ar_flutter_plugin: ^0.7.3
  path_provider: ^2.1.1
  http: ^1.1.0
  provider: ^6.0.5
```

### Permisos Necesarios

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera.ar" android:required="true" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para realidad aumentada</string>
```

## 📱 Uso del Motor

### 1. Inicialización

```dart
// En tu pantalla principal
class ARViewScreen extends StatefulWidget {
  final Pieza pieza;
  
  @override
  Widget build(BuildContext context) {
    return ARView(
      onARViewCreated: onARViewCreated,
    );
  }
}
```

### 2. Carga de Modelos

```dart
// Cargar modelo desde URL
final modelPath = await ModelLoader.cargarModeloDesdeUrl(
  pieza.urlModelo3D,
  pieza.id,
);

// Crear nodo AR
final newNode = ARNode(
  type: NodeType.localGLTF2,
  uri: modelPath,
  scale: Vector3.all(pieza.escala),
  position: Vector3.fromList(pieza.posicionInicial),
);
```

### 3. Gestión de Estado

```dart
// Usar el provider
final arProvider = Provider.of<ARProvider>(context);

// Seleccionar pieza
await arProvider.seleccionarPieza(pieza);

// Verificar estado
if (arProvider.modelLoaded) {
  // Modelo listo para mostrar
}
```

## 🔄 Flujo de Trabajo

1. **Selección de Pieza**: Usuario selecciona una pieza cultural
2. **Verificación**: Sistema verifica disponibilidad del modelo 3D
3. **Pre-carga**: Modelo se descarga y almacena en caché
4. **Inicialización AR**: Se inicia la sesión de realidad aumentada
5. **Detección de Planos**: Sistema detecta superficies disponibles
6. **Colocación**: Modelo se posiciona en el espacio real
7. **Interacción**: Usuario puede manipular el objeto virtual

## 🎨 Personalización

### Configuración de Modelos

```dart
// En ar_config.dart
static const double defaultScale = 1.0;
static const List<double> defaultPosition = [0.0, 0.0, 0.0];
static const bool enableShadows = true;
static const bool enableLighting = true;
```

### Configuración de UI

```dart
// Personalizar paneles de información
static const double infoPanelOpacity = 0.8;
static const Duration animationDuration = Duration(milliseconds: 300);
```

## 🚨 Solución de Problemas

### Error: "Modelo no disponible"
- Verificar URL del modelo 3D
- Comprobar conexión a internet
- Revisar formato del archivo (.glb/.gltf)

### Error: "Cámara no disponible"
- Verificar permisos de cámara
- Comprobar compatibilidad del dispositivo
- Revisar configuración de ARCore/ARKit

### Error: "Memoria insuficiente"
- Limpiar caché de modelos
- Reducir calidad de modelos
- Optimizar configuración de rendimiento

## 📈 Optimización

### Rendimiento
- Usar modelos optimizados (LOD)
- Implementar pre-carga inteligente
- Configurar límites de caché

### Calidad Visual
- Habilitar sombras y iluminación
- Usar texturas de alta calidad
- Configurar anti-aliasing

## 🔮 Próximas Mejoras

- [ ] Tracking de imágenes
- [ ] Animaciones personalizadas
- [ ] Colaboración multi-usuario
- [ ] Reconocimiento de gestos avanzados
- [ ] Integración con IA para interpretación

## 📞 Soporte

Para problemas técnicos o consultas sobre el motor de RA, contactar al equipo de desarrollo de Disruptón.
