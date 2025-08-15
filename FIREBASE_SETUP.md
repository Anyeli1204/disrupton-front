# Configuración de Firebase App Distribution

## ¿Por qué Firebase App Distribution?

- ✅ **Gratuito** para hasta 100 testers
- ✅ **Más estable** que AltStore
- ✅ **No requiere jailbreak**
- ✅ **Fácil instalación** en iPhone
- ✅ **Notificaciones automáticas** a testers

## Paso 1: Configurar Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o usa uno existente
3. Agrega una app iOS:
   - Bundle ID: `com.disrupton.app`
   - Nombre: `Disrupton App`

## Paso 2: Configurar Firebase CLI

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login a Firebase
firebase login

# Inicializar Firebase en tu proyecto
firebase init appdistribution
```

## Paso 3: Configurar Variables en Codemagic

En Codemagic, agrega estas variables de entorno:

- `FIREBASE_APP_ID`: Tu Firebase App ID (ej: 1:123456789:ios:abcdef123456)
- `FIREBASE_TOKEN`: Tu Firebase token (generado con `firebase login:ci`)

## Paso 4: Agregar Testers

1. En Firebase Console → App Distribution
2. Ve a "Testers & groups"
3. Agrega tu email como tester
4. Crea un grupo llamado "testers"

## Paso 5: Ejecutar Build

1. En Codemagic, usa el workflow `firebase-distribution`
2. El IPA se subirá automáticamente a Firebase
3. Recibirás un email con el link de descarga

## Paso 6: Instalar en iPhone

1. Abre el email de Firebase en tu iPhone
2. Toca "Download" o "Install"
3. Confirma la instalación
4. Ve a Configuración → General → Gestión de dispositivos
5. Confía en el certificado de desarrollador

## Ventajas sobre AltStore:

- ✅ No requiere servidor local
- ✅ No requiere jailbreak
- ✅ Actualizaciones automáticas
- ✅ Más estable y confiable
- ✅ Soporte oficial de Google

## Troubleshooting:

### Error de certificado:
- Ve a Configuración → General → Gestión de dispositivos
- Confía en el certificado de desarrollador

### App no se instala:
- Asegúrate de que el Bundle ID coincida
- Verifica que tu email esté en la lista de testers

### Build falla:
- Verifica las variables de entorno en Codemagic
- Asegúrate de que Firebase CLI esté configurado correctamente
