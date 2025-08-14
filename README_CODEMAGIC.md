# 🚀 Guía para Probar en iPhone 15 con Codemagic

## 📋 Requisitos Previos

### **1. Cuenta de Apple Developer**
- Necesitas una cuenta de Apple Developer ($99/año)
- O usar una cuenta gratuita (limitaciones)

### **2. Cuenta de Codemagic**
- Registrarse en [codemagic.io](https://codemagic.io)
- Conectar tu repositorio de GitHub

## 🛠️ Configuración Paso a Paso

### **Paso 1: Subir Código a GitHub**

1. Crear un repositorio en GitHub
2. Subir tu código:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tu-usuario/disrupton-app.git
git push -u origin main
```

### **Paso 2: Configurar Codemagic**

1. **Ir a [codemagic.io](https://codemagic.io)**
2. **Conectar tu repositorio de GitHub**
3. **Seleccionar el repositorio**
4. **Configurar variables de entorno:**

#### **Variables Necesarias:**
```
CM_CERTIFICATE_PASSWORD = [tu-contraseña]
CM_KEYCHAIN_PASSWORD = [tu-contraseña]
CM_TEAM_ID = [tu-team-id]
CM_DEVELOPMENT_TEAM = [tu-team-id]
CM_APP_STORE_CONNECT_PRIVATE_KEY = [tu-api-key]
CM_APP_STORE_CONNECT_KEY_IDENTIFIER = [tu-key-id]
CM_APP_STORE_CONNECT_ISSUER_ID = [tu-issuer-id]
```

### **Paso 3: Obtener Credenciales de Apple**

#### **Para Cuenta Gratuita:**
1. Ir a [developer.apple.com](https://developer.apple.com)
2. Crear certificado de desarrollo
3. Crear perfil de aprovisionamiento
4. Obtener Team ID

#### **Para Cuenta Pagada:**
1. Crear App ID en App Store Connect
2. Generar API Key
3. Configurar certificados de distribución

### **Paso 4: Ejecutar Build**

1. **En Codemagic, ir a "Build"**
2. **Seleccionar "iOS Workflow"**
3. **Hacer clic en "Start new build"**
4. **Esperar a que termine la compilación**

## 📱 Instalación en iPhone 15

### **Opción A: TestFlight (Recomendado)**

1. **Codemagic subirá automáticamente a TestFlight**
2. **Recibirás un email de Apple**
3. **Instalar TestFlight en tu iPhone 15**
4. **Aceptar la invitación**
5. **Instalar la app desde TestFlight**

### **Opción B: Instalación Directa**

1. **Descargar el .ipa desde Codemagic**
2. **Usar herramientas como AltStore o Sideloadly**
3. **Instalar en tu iPhone 15**

## 🔧 Configuración del iPhone 15

### **Permisos Necesarios:**
- ✅ Cámara (para RA)
- ✅ Ubicación (para AR)
- ✅ Micrófono (para audio)

### **Configuración de ARKit:**
- ✅ iOS 17+ (tu iPhone 15 lo tiene)
- ✅ ARKit compatible (iPhone 15 lo es)
- ✅ Espacio suficiente para tracking

## 🧪 Probar la Realidad Aumentada

### **1. Abrir la App**
- La app se abrirá en tu iPhone 15
- Permitir permisos cuando se soliciten

### **2. Probar Funcionalidades**
- **Detección de Planos**: Mover el iPhone por superficies
- **Colocación de Modelos**: Tocar para colocar objetos 3D
- **Interacción**: Usar gestos para manipular objetos

### **3. Verificar Funcionalidades**
- ✅ Carga de modelos 3D
- ✅ Detección de superficies
- ✅ Interacción táctil
- ✅ Información contextual

## 🚨 Solución de Problemas

### **Error: "No se puede instalar"**
- Verificar certificados en Codemagic
- Comprobar Bundle ID
- Revisar Team ID

### **Error: "AR no funciona"**
- Verificar permisos de cámara
- Comprobar espacio de tracking
- Revisar iluminación

### **Error: "Modelos no cargan"**
- Verificar URLs de modelos 3D
- Comprobar conexión a internet
- Revisar formato de archivos (.glb/.gltf)

## 📞 Soporte

- **Codemagic Docs**: [docs.codemagic.io](https://docs.codemagic.io)
- **Apple Developer**: [developer.apple.com](https://developer.apple.com)
- **Flutter Docs**: [docs.flutter.dev](https://docs.flutter.dev)

## 🎯 Próximos Pasos

1. **Configurar GitHub Actions** (alternativa gratuita)
2. **Implementar CI/CD completo**
3. **Configurar distribución automática**
4. **Optimizar para producción**
