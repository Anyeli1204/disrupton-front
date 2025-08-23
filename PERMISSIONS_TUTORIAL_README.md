# Sistema de Permisos y Tutorial - Disrupton App

## Descripción General

Este sistema implementa un flujo inteligente de permisos y tutorial que se adapta al comportamiento del usuario y solo muestra los pop-ups cuando es realmente necesario.

## Características Principales

### 🔐 Sistema de Permisos Inteligente

- **Persistencia de Estados**: Cada permiso guarda su estado (concedido, denegado, etc.)
- **Lógica Inteligente de Pop-ups**: Solo muestra permisos cuando:
  - Es un usuario nuevo (primera vez)
  - El usuario eligió "Solo esta vez" en la sesión anterior
  - El permiso fue denegado pero no permanentemente
- **No Molesta al Usuario**: No muestra pop-ups si:
  - Ya eligió "Permitir mientras la app esté en uso"
  - El permiso fue denegado permanentemente
  - Ya tiene el permiso concedido

### 📱 Permisos Implementados

1. **Cámara**: Para AR y capturas de objetos culturales
2. **Galería de Fotos**: Para acceso a imágenes del usuario

### 🎓 Tutorial para Usuarios Regulares

- **Solo para Rol USER**: Tutorial interactivo de 5 pantallas
- **Una Sola Vez**: Se marca como completado y no se vuelve a mostrar
- **Navegación Fluida**: Con indicadores de progreso y animaciones

### 🔄 Flujo de Navegación

```
Splash Screen
    ↓
¿Autenticado?
    ↓ (Sí)
¿Necesita Rol?
    ↓ (No)
¿Permisos Pendientes? O ¿Tutorial Pendiente?
    ↓ (Sí)
Permission Flow Manager
    ↓
Pop-ups de Permisos (secuencial)
    ↓
Tutorial (solo USER, solo primera vez)
    ↓
Home Screen
```

## Archivos Creados/Modificados

### Nuevos Archivos

1. **`lib/models/permission_models.dart`**
   - Enums: `PermissionStatus`, `PermissionType`
   - Clase: `PermissionState` con lógica de `shouldShowPopup`

2. **`lib/services/permission_service.dart`**
   - Gestión de estados de permisos con SharedPreferences
   - Mapeo entre permisos del sistema y nuestros modelos
   - Control de tutorial completado

3. **`lib/screens/permission_popup_screen.dart`**
   - Pop-up animado con opciones:
     - "Permitir mientras la aplicación esté en uso"
     - "Solo esta vez"
     - "No permitir"

4. **`lib/screens/tutorial_screen.dart`**
   - Tutorial de 5 pantallas con PageView
   - Animaciones fluidas y diseño atractivo
   - Solo para usuarios con rol USER

5. **`lib/screens/permission_flow_manager.dart`**
   - Coordina la secuencia de permisos y tutorial
   - Maneja la navegación entre estados

### Archivos Modificados

1. **`lib/screens/splash_screen.dart`**
   - Integra verificación de permisos pendientes
   - Navegación hacia PermissionFlowManager cuando es necesario

2. **`lib/screens/role_selection_screen.dart`**
   - Después de seleccionar rol USER, verifica si necesita permisos/tutorial
   - Navega al flujo apropiado

## Lógica de Decisión de Pop-ups

El sistema usa la propiedad `shouldShowPopup` en `PermissionState`:

```dart
bool get shouldShowPopup {
  // No mostrar si ya está concedido y usuario eligió "allow while using app"
  if (status == PermissionStatus.granted && allowWhileUsingApp) {
    return false;
  }

  // Mostrar si usuario eligió "solo esta vez" en sesión anterior
  if (onlyThisTime && status != PermissionStatus.granted) {
    return true;
  }

  // Mostrar para usuarios nuevos
  if (!hasAskedBefore) {
    return true;
  }

  // No mostrar si fue denegado permanentemente
  if (status == PermissionStatus.permanentlyDenied || 
      status == PermissionStatus.restricted) {
    return false;
  }

  // Mostrar si fue denegado pero no permanentemente
  return status == PermissionStatus.denied;
}
```

## Casos de Uso

### Usuario Nuevo
1. Se registra y selecciona rol
2. Si selecciona USER: → Permisos → Tutorial → Home
3. Si selecciona otro rol: → Permisos → Home

### Usuario Existente que Eligió "Solo Esta Vez"
1. Abre la app
2. Sistema detecta `onlyThisTime = true`
3. Muestra pop-up de permisos nuevamente

### Usuario que Eligió "Permitir Mientras Uso la App"
1. Abre la app
2. No se muestran pop-ups
3. Va directo a Home

### Usuario que Denegó Permanentemente
1. Abre la app
2. No se muestran pop-ups (para no molestar)
3. Va directo a Home

## Dependencias Utilizadas

- `permission_handler: ^12.0.1` - Manejo de permisos del sistema
- `shared_preferences: ^2.2.2` - Persistencia de estados
- `provider: ^6.0.5` - Gestión de estado

## Testing

Para probar el sistema:

1. **Reset Tutorial**: Usar `PermissionService.resetTutorial()`
2. **Borrar Estados**: Eliminar datos de SharedPreferences
3. **Simular Nuevos Usuarios**: Crear nuevas cuentas con rol USER
4. **Verificar Flujos**: Probar diferentes combinaciones de permisos

## Futuras Mejoras

- [ ] Soporte para más tipos de permisos (ubicación, micrófono)
- [ ] Analytics de uso de permisos
- [ ] Tutorial personalizado por rol
- [ ] Recordatorios inteligentes para permisos denegados
