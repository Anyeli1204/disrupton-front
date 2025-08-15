# Guía Paso a Paso: Configuración Firebase

## Paso 1: Obtener FIREBASE_APP_ID

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Configuración del proyecto** (ícono de engranaje)
4. En la pestaña **General**, busca **"ID de la app"**
5. Copia el ID que aparece (formato: `1:123456789:ios:abcdef123456`)

## Paso 2: Obtener FIREBASE_TOKEN

### Opción A: Desde Firebase Console
1. Ve a **Configuración del proyecto** → **Cuentas de servicio**
2. Haz clic en **"Generar nueva clave privada"**
3. Descarga el archivo JSON
4. El token está en el campo `private_key_id`

### Opción B: Desde Firebase CLI (Recomendado)
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Generar token
firebase login:ci
```

## Paso 3: Configurar Variables en Codemagic

1. Ve a tu proyecto en [Codemagic](https://codemagic.io/)
2. Ve a **Settings** → **Environment variables**
3. Agrega estas variables:

| Variable | Valor |
|----------|-------|
| `FIREBASE_APP_ID` | El ID que copiaste en Paso 1 |
| `FIREBASE_TOKEN` | El token que obtuviste en Paso 2 |

## Paso 4: Agregar GoogleService-Info.plist

1. Descarga el archivo `GoogleService-Info.plist` de Firebase Console
2. Colócalo en: `frontend/ios/Runner/GoogleService-Info.plist`
3. Asegúrate de que esté incluido en el proyecto Xcode

## Paso 5: Ejecutar Build

1. En Codemagic, selecciona el workflow `firebase-distribution`
2. Ejecuta el build
3. El IPA se subirá automáticamente a Firebase
4. Recibirás un email con el link de descarga

## Verificación

Para verificar que todo está configurado correctamente:

1. **Firebase Console** → **App Distribution** → Deberías ver tu app
2. **Codemagic** → Las variables de entorno están configuradas
3. **Email** → Recibirás notificación cuando el build esté listo
