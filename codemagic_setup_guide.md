# Configuración Codemagic - Guía Paso a Paso

## Configuración Actual en la Pantalla:

### ✅ Lo que está bien:
- **Project type:** Flutter ✅
- **Build stack:** Xcode 16.4.x ✅
- **Build machine:** M2 Pro Large ✅

### 🔧 Lo que necesitas cambiar:

#### **1. Project location:**
**Cambia de:** `.`  
**A:** `frontend`

**Explicación:** Tu proyecto Flutter está en la carpeta `frontend`, no en la raíz.

#### **2. Pasos en la interfaz:**

1. **En "Project location":**
   - Cambia el valor de `.` a `frontend`
   - Esto le dice a Codemagic dónde está tu proyecto Flutter

2. **Haz clic en "Next" o "Continue"**

3. **En la siguiente pantalla:**
   - Selecciona tu rama principal (main)
   - Confirma la configuración

#### **3. Configurar variables de entorno:**

Después de crear el proyecto, ve a:
- **Settings** → **Environment Variables**
- Agrega estas variables:

| Variable | Valor |
|----------|-------|
| `BUNDLE_ID` | `com.disrupton.app` |
| `TEAM_ID` | (tu Team ID de Apple) |

#### **4. Configurar certificados:**

En **Settings** → **Code Signing**:
- **iOS Code Signing:** Auto
- **Certificate:** Development
- **Provisioning Profile:** Auto

## ¿Necesitas ayuda con algún paso específico?
