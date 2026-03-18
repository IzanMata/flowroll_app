# FlowRoll

> BJJ Academy Management — attendance, athletes, tatami & match tracking in one app.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![CI](https://github.com/your-org/flowroll_app/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/flowroll_app/actions/workflows/ci.yml)

---

## ✨ Features

| Módulo | Descripción |
|--------|-------------|
| 🏫 **Academias** | Selector multi-academia, gestión de academias |
| 👥 **Atletas** | CRUD completo, cinturones, roles (profesor/alumno), búsqueda y filtros |
| 📋 **Asistencia** | Clases, check-in manual, QR check-in, drop-ins |
| 🥊 **Partidos** | Lista de combates, pantalla live, historial |
| 🏋️ **Tatami** | Emparejamientos, temporizadores de ronda, categorías de peso |
| 📚 **Técnicas** | Currículum por cinturón, categorías, variaciones |
| 🔐 **Auth** | JWT con refresh automático, almacenamiento seguro |

---

## 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                     FlowRoll App                        │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │Academies │  │ Athletes │  │Attendance│  │Matches │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘ │
│       │              │              │              │     │
│  ┌────▼──────────────▼──────────────▼──────────────▼──┐ │
│  │              Domain Layer (Riverpod)                │ │
│  │   Providers · StateNotifiers · FutureProviders      │ │
│  └────────────────────────┬────────────────────────────┘ │
│                           │                             │
│  ┌────────────────────────▼────────────────────────────┐ │
│  │                 Data Layer                          │ │
│  │    Repositories → DioClient → JWT Interceptor       │ │
│  └────────────────────────┬────────────────────────────┘ │
└───────────────────────────┼─────────────────────────────┘
                            │ HTTPS/REST (JWT)
                ┌───────────▼────────────┐
                │   Backend API          │
                │   Django REST + JWT    │
                │   localhost:8080       │
                └────────────────────────┘
```

**Stack:**
- **UI:** Flutter 3.x + Material 3 (tema dark custom)
- **Estado:** Riverpod 2 + Flutter Hooks
- **Navegación:** Go Router 13 (shell routes)
- **HTTP:** Dio 5 + JWT interceptor (auto-refresh)
- **Almacenamiento:** Flutter Secure Storage (tokens) + SharedPreferences
- **QR:** qr_flutter (generación) + mobile_scanner (escaneo)
- **Fuentes:** Google Fonts (Bebas Neue)
- **Backend:** Django REST Framework + SimpleJWT (repositorio separado)

---

## 🚀 Quick Start

### Prerequisitos

```bash
flutter --version   # >= 3.19
dart --version      # >= 3.3
```

### 1. Clonar y configurar

```bash
git clone https://github.com/your-org/flowroll_app.git
cd flowroll_app
cp .env.example .env
flutter pub get
```

### 2. Configurar el backend

El backend (Django REST) debe estar corriendo en `http://localhost:8080`.
Ver repositorio: `https://github.com/your-org/flowroll_backend`

### 3. Ejecutar

```bash
# Android / iOS
flutter run --dart-define-from-file=.env

# Chrome (web)
flutter run -d chrome --dart-define-from-file=.env

# Con URL del backend personalizada
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080
```

> **Tip:** Para listar dispositivos disponibles: `flutter devices`

---

## ⚙️ Configuración

Todas las variables se inyectan en compile-time via `--dart-define`:

| Variable | Descripción | Default |
|----------|-------------|---------|
| `API_BASE_URL` | URL base del backend | `http://localhost:8080` |

Crea un archivo `.env` (usado con `--dart-define-from-file=.env`):

```
API_BASE_URL=http://localhost:8080
```

> **Nota:** En producción usa la URL HTTPS de tu backend. Ver [DEPLOYMENT.md](DEPLOYMENT.md).

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                   # Entry point
├── core/
│   ├── api/                    # DioClient, interceptores, constantes
│   ├── auth/                   # Provider de autenticación, token storage
│   ├── router/                 # GoRouter — rutas y guardas de auth
│   └── theme/                  # Colores, tipografía, espaciado, strings
├── features/                   # Módulos por dominio
│   ├── academies/
│   ├── athletes/
│   ├── attendance/
│   ├── auth/
│   ├── matches/
│   ├── tatami/
│   └── techniques/
└── shared/
    ├── models/                 # Data models (PODOs)
    └── widgets/                # Widgets reutilizables
```

Cada feature sigue arquitectura limpia en 3 capas:

```
feature/
├── data/          # Repository (Dio calls)
├── domain/        # Riverpod providers
└── presentation/  # Screens (ConsumerWidget)
```

---

## 🔧 Desarrollo Local

### Comandos útiles

```bash
# Instalar dependencias
flutter pub get

# Analizar código
flutter analyze

# Formatear
dart format lib/ test/

# Tests
flutter test

# Tests con coverage
flutter test --coverage

# Build APK debug
flutter build apk --debug

# Build web
flutter build web --dart-define=API_BASE_URL=https://api.yourdomain.com
```

### Make (ver [Makefile](Makefile))

```bash
make setup       # flutter pub get
make dev         # flutter run -d chrome
make analyze     # flutter analyze + dart format --set-exit-if-changed
make test        # flutter test --coverage
make build-apk   # flutter build apk --release
make build-web   # flutter build web
```

---

## 🧪 Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/features/athletes/

# Con coverage
flutter test --coverage
```

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para convenciones de testing.

---

## 🚢 Deploy a Producción

Ver [DEPLOYMENT.md](DEPLOYMENT.md) para guías completas de:
- Android (Google Play Store)
- iOS (Apple App Store)
- Web (Firebase Hosting / Vercel)

---

## 📡 API Reference

La app consume una REST API con autenticación JWT. Endpoints principales:

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/auth/token/` | Login — obtener access + refresh token |
| `POST` | `/api/auth/token/refresh/` | Renovar access token |
| `GET` | `/api/academies/` | Listar academias |
| `GET/POST` | `/api/athletes/` | Atletas |
| `GET/POST` | `/api/attendance/classes/` | Clases |
| `POST` | `/api/attendance/classes/manual_checkin/` | Check-in manual |
| `POST` | `/api/attendance/classes/qr_checkin/` | Check-in por QR |
| `GET/POST` | `/api/matches/` | Combates |
| `GET/POST` | `/api/tatami/matchups/` | Emparejamientos |
| `GET` | `/api/tatami/timer-presets/` | Presets de temporizador |
| `GET` | `/api/techniques/techniques/` | Técnicas |

Ver documentación completa del backend en su repositorio.

---

## 🗺️ Roadmap

- [ ] **v1.1** — Push notifications (asistencia, combates)
- [ ] **v1.2** — Modo offline con sincronización
- [ ] **v1.3** — Estadísticas y gráficas de rendimiento
- [ ] **v1.4** — Calendario de clases
- [ ] **v2.0** — Multi-idioma (i18n)

---

## 🤝 Contribución

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para la guía completa.

```bash
# Fork → branch → PR
git checkout -b feat/nombre-feature
# ... cambios ...
git commit -m "feat(athletes): add photo upload"
git push origin feat/nombre-feature
# Abrir PR contra main
```

---

## 📄 Licencia

MIT © 2024 FlowRoll. Ver [LICENSE](LICENSE).
