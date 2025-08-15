# Configuración EAS Build - Guía Completa

## ¿Por qué EAS Build?

✅ **100% GRATUITO** para uso básico  
✅ **Mantienes tu código Flutter**  
✅ **Build nativo** (funciona en iPhone físico)  
✅ **No requiere certificados de Apple**  
✅ **Instalación directa en iPhone**  
✅ **Perfecto para apps de AR**  

## Paso 1: Instalar EAS CLI

```bash
npm install -g @expo/eas-cli
```

## Paso 2: Login a Expo

```bash
eas login
```

## Paso 3: Configurar EAS en tu proyecto

```bash
eas build:configure
```

## Paso 4: Crear eas.json

```json
{
  "cli": {
    "version": ">= 5.9.1"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
```

## Paso 5: Build para desarrollo

```bash
eas build --platform ios --profile development
```

## Paso 6: Instalar en iPhone

1. **Recibirás un email** con el link de descarga
2. **Abrir el link** en tu iPhone
3. **Instalar directamente**

## Ventajas sobre Diawi:

- ✅ **Build nativo** (no simulador)
- ✅ **Funciona en iPhone físico**
- ✅ **Mejor para AR**
- ✅ **Más profesional**
- ✅ **Soporte oficial**

## ¿Empezamos con EAS Build?
