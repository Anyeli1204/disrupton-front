# Configuración Bitrise - Guía Completa

## ¿Por qué Bitrise?

✅ **100% GRATUITO** para uso básico  
✅ **Certificados automáticos** incluidos  
✅ **Build para iPhone físico**  
✅ **No requiere configuración manual**  
✅ **Perfecto para Flutter**  
✅ **Instalación directa en iPhone**  

## Paso 1: Crear cuenta en Bitrise

1. **Ve a [Bitrise.io](https://bitrise.io/)**
2. **Haz clic en "Get Started for Free"**
3. **Crea una cuenta** con tu email
4. **Conecta tu cuenta de GitHub**

## Paso 2: Agregar tu proyecto

1. **Haz clic en "Add New App"**
2. **Selecciona tu repositorio** `disrupton-front`
3. **Bitrise detectará automáticamente** que es Flutter
4. **Confirma la configuración**

## Paso 3: Configurar certificados

1. **Ve a "Workflow Editor"**
2. **En "Code Signing"** → **"iOS Code Signing"**
3. **Selecciona "Auto"** para certificados automáticos
4. **Guarda la configuración**

## Paso 4: Configurar variables de entorno

En **"Workflow Editor"** → **"Environment Variables"**:

| Variable | Valor |
|----------|-------|
| `FLUTTER_VERSION` | `3.19.0` |
| `PROJECT_LOCATION` | `frontend` |

## Paso 5: Ejecutar el build

1. **Haz clic en "Start/Schedule a Build"**
2. **Selecciona "Primary"** workflow
3. **Espera a que termine** (5-10 minutos)

## Paso 6: Instalar en iPhone

1. **Ve a "Artifacts"** en el build completado
2. **Descarga el archivo `.ipa`**
3. **Instala usando AltStore** o similar

## Ventajas sobre otras opciones:

- ✅ **Certificados automáticos** (no necesitas Apple Developer)
- ✅ **Build nativo** (funciona en iPhone físico)
- ✅ **Configuración automática** para Flutter
- ✅ **Más fácil** que CodeMagic
- ✅ **Gratuito** para uso básico

## ¿Empezamos con Bitrise?
