# Migración a Expo Go - Guía Completa

## ¿Por qué Expo Go?

✅ **100% GRATUITO**  
✅ **No requiere certificados de Apple**  
✅ **Instalación directa en iPhone**  
✅ **Perfecto para apps de AR**  
✅ **Desarrollo más rápido**  

## Paso 1: Instalar Expo CLI

```bash
npm install -g @expo/cli
```

## Paso 2: Crear proyecto Expo

```bash
# Crear nuevo proyecto
expo init disrupton-expo

# O migrar proyecto existente
expo install
```

## Paso 3: Configurar dependencias

```json
{
  "dependencies": {
    "expo": "~50.0.0",
    "expo-camera": "~14.0.0",
    "expo-gl": "~13.6.0",
    "expo-three": "^7.0.0",
    "three": "^0.160.0",
    "react": "18.2.0",
    "react-native": "0.73.0"
  }
}
```

## Paso 4: Configurar AR

```javascript
import { AR } from 'expo-three';

// Configuración de AR más simple
```

## Paso 5: Build y distribución

```bash
# Build para desarrollo
expo start

# Build para producción
expo build:ios
```

## Ventajas sobre Flutter:

- ✅ **No requiere certificados**
- ✅ **Instalación directa con QR**
- ✅ **Hot reload más rápido**
- ✅ **Mejor soporte para AR**
- ✅ **Comunidad más grande**

## ¿Quieres migrar a Expo?
