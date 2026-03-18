# Deployment Guide — FlowRoll

## Índice

1. [Pre-deploy Checklist](#pre-deploy-checklist)
2. [Android — Google Play Store](#android--google-play-store)
3. [iOS — Apple App Store](#ios--apple-app-store)
4. [Web — Firebase Hosting](#web--firebase-hosting)
5. [Web — Vercel](#web--vercel)
6. [Variables de Entorno en Producción](#variables-de-entorno-en-producción)
7. [CI/CD](#cicd)

---

## Pre-deploy Checklist

Antes de cualquier release:

- [ ] `flutter analyze` sin errores
- [ ] `flutter test` todos los tests pasan
- [ ] `API_BASE_URL` apunta a la URL HTTPS de producción
- [ ] Backend en producción operativo y con HTTPS
- [ ] Versión y build number actualizados en `pubspec.yaml`
- [ ] `CHANGELOG.md` actualizado
- [ ] Android: keystore de release configurado (no debug signing)
- [ ] iOS: certificados y provisioning profiles vigentes

---

## Android — Google Play Store

### 1. Crear el keystore de firma

```bash
keytool -genkey -v \
  -keystore android/app/flowroll-release.jks \
  -alias flowroll \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> **IMPORTANTE:** Guarda el keystore y las contraseñas de forma segura.
> Nunca commits el `.jks` al repositorio.

### 2. Configurar key.properties

Crea `android/key.properties` (está en `.gitignore`):

```properties
storePassword=TU_STORE_PASSWORD
keyPassword=TU_KEY_PASSWORD
keyAlias=flowroll
storeFile=flowroll-release.jks
```

### 3. Actualizar android/app/build.gradle

```groovy
// Añadir antes de android {}
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true          // habilitar en producción
            shrinkResources true
        }
    }
}
```

### 4. Build

```bash
flutter build appbundle \
  --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com
```

El archivo generado: `build/app/outputs/bundle/release/app-release.aab`

### 5. Subir a Play Console

1. Ir a [Google Play Console](https://play.google.com/console)
2. Crear app → Producción → Subir el `.aab`
3. Completar ficha de la tienda (descripción, capturas, etc.)
4. Revisar y publicar

---

## iOS — Apple App Store

### Prerrequisitos

- Cuenta Apple Developer ($99/año)
- Xcode instalado (macOS)
- Certificado de distribución y provisioning profile

### 1. Configurar en Xcode

```bash
open ios/Runner.xcworkspace
```

En Xcode:
- Seleccionar target `Runner`
- Signing & Capabilities → Team: tu equipo Apple
- Bundle Identifier: `com.flowroll.app` (o el tuyo)
- Version y Build actualizados

### 2. Build

```bash
flutter build ipa \
  --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com
```

### 3. Subir a App Store Connect

```bash
# Via Transporter o xcrun altool
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --apiKey TU_API_KEY \
  --apiIssuer TU_ISSUER_ID
```

O arrastra el `.ipa` a Transporter.app.

### 4. App Store Connect

1. [App Store Connect](https://appstoreconnect.apple.com)
2. Nueva versión → Subir build
3. Completar metadata (descripción, capturas, age rating)
4. Enviar para revisión

---

## Web — Firebase Hosting

### 1. Instalar Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. Inicializar proyecto

```bash
firebase init hosting
# Public directory: build/web
# Single-page app: Yes
# GitHub actions: No (configuramos manualmente)
```

### 3. Build

```bash
flutter build web \
  --release \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --web-renderer canvaskit
```

### 4. Deploy

```bash
firebase deploy --only hosting
```

### 5. Custom domain (opcional)

En Firebase Console → Hosting → Add custom domain → Seguir los pasos DNS.

---

## Web — Vercel

### 1. Build script

Añadir en `package.json` (si usas Vercel):

```json
{
  "scripts": {
    "build": "flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL"
  }
}
```

O configurar en Vercel Dashboard:
- Build Command: `flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL`
- Output Directory: `build/web`
- Install Command: `flutter pub get`

### 2. Variables de entorno en Vercel

En Vercel Dashboard → Settings → Environment Variables:
```
API_BASE_URL = https://api.yourdomain.com
```

---

## Variables de Entorno en Producción

Las variables se inyectan en compile-time. Para CI/CD:

| Variable | Descripción | Obligatoria |
|----------|-------------|-------------|
| `API_BASE_URL` | URL HTTPS del backend | Sí |

### En GitHub Actions

```yaml
- name: Build Android
  run: |
    flutter build appbundle \
      --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }}
```

### Secrets necesarios en GitHub

| Secret | Descripción |
|--------|-------------|
| `API_BASE_URL` | URL del backend de producción |
| `ANDROID_KEYSTORE_BASE64` | Keystore codificado en base64 |
| `ANDROID_KEY_ALIAS` | Alias de la clave |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave |
| `ANDROID_STORE_PASSWORD` | Contraseña del keystore |
| `FIREBASE_TOKEN` | Token para Firebase CLI deploy |

### Codificar el keystore para GitHub Secrets

```bash
base64 -i android/app/flowroll-release.jks | pbcopy
# Pegar en el secret ANDROID_KEYSTORE_BASE64
```

---

## CI/CD

Ver `.github/workflows/ci.yml` para el pipeline completo que incluye:
- Análisis de código
- Tests
- Build para Android/iOS/Web en pushes a `main`
- Deploy automático a Firebase Hosting

---

## Requisitos de Infraestructura (Backend)

El backend Django necesita:

| Recurso | Mínimo recomendado |
|---------|-------------------|
| CPU | 1 vCPU |
| RAM | 512 MB |
| Almacenamiento | 10 GB SSD |
| Base de datos | PostgreSQL 14+ |
| HTTPS | Obligatorio (Let's Encrypt) |

**Costos estimados (AWS):**
- EC2 t3.micro: ~$8/mes
- RDS db.t3.micro (PostgreSQL): ~$13/mes
- **Total estimado: ~$21/mes para un MVP**

Alternativas económicas:
- [Railway](https://railway.app): desde $5/mes, PostgreSQL incluido
- [Render](https://render.com): free tier disponible
- [Fly.io](https://fly.io): free tier con limitaciones
