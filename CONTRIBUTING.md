# Contributing to FlowRoll

## Índice

1. [Setup del entorno](#setup-del-entorno)
2. [Estructura de ramas](#estructura-de-ramas)
3. [Convenciones de código](#convenciones-de-código)
4. [Convenciones de commits](#convenciones-de-commits)
5. [Testing](#testing)
6. [Proceso de PR](#proceso-de-pr)
7. [Añadir un nuevo feature](#añadir-un-nuevo-feature)

---

## Setup del Entorno

### 1. Instalar Flutter

```bash
# Instalar Flutter SDK (https://flutter.dev/docs/get-started/install)
flutter --version  # Debe ser >= 3.19
```

### 2. Clonar y configurar

```bash
git clone https://github.com/your-org/flowroll_app.git
cd flowroll_app
cp .env.example .env
flutter pub get
```

### 3. Verificar instalación

```bash
flutter doctor      # Todos los checks deben pasar
flutter analyze     # Debe terminar sin errores
flutter test        # Todos los tests deben pasar
```

### 4. IDE recomendado

**VS Code** con extensiones:
- Flutter
- Dart
- Flutter Riverpod Snippets
- Error Lens

**Android Studio** con plugins:
- Flutter
- Dart

Configuración de VS Code (`.vscode/settings.json`):

```json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true
  },
  "dart.lineLength": 100
}
```

---

## Estructura de Ramas

```
main          ← producción, siempre estable
develop       ← integración (opcional para equipos)
feat/*        ← nuevas funcionalidades
fix/*         ← correcciones de bugs
chore/*       ← mantenimiento, dependencias, config
docs/*        ← solo documentación
refactor/*    ← refactorizaciones sin cambio de comportamiento
```

Ejemplos:
```bash
feat/athlete-photo-upload
fix/qr-scanner-torch-state
chore/update-dependencies
docs/deployment-guide
```

---

## Convenciones de Código

### Dart / Flutter

- **Longitud de línea:** 100 caracteres
- **Nombrado:**
  - Clases: `PascalCase`
  - Variables, métodos: `camelCase`
  - Constantes: `camelCase` (Dart no usa UPPER_SNAKE para constantes)
  - Archivos: `snake_case.dart`
- **Privacidad:** Prefijo `_` para campos y métodos privados

### Widgets

```dart
// ✅ Bien — widget pequeño como clase separada
class _AthleteCard extends StatelessWidget { ... }

// ✅ Bien — const donde sea posible
const SizedBox(height: 16)

// ❌ Evitar — lógica de negocio en widgets
onTap: () async {
  final result = await dio.get(...); // ← esto va en un repository
}
```

### Providers

```dart
// ✅ autoDispose en providers de datos remotos
final athletesProvider = FutureProvider.autoDispose.family<...>((ref, filter) async { ... });

// ✅ Filtros con == y hashCode correctos
class AthletesFilter {
  @override bool operator ==(Object other) => ...;
  @override int get hashCode => Object.hash(...);
}

// ✅ Invalidación explícita al mutar datos
ref.invalidate(athletesProvider(filter));
```

### Imports

Orden de imports (enforced por `dart format`):
1. `dart:*`
2. `package:flutter/*`
3. Paquetes externos
4. Imports relativos del proyecto

```dart
// ✅ Bien
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

// ❌ Evitar imports absolutos del paquete para código interno
import 'package:flowroll_app/core/theme/app_colors.dart'; // usar relativo
```

### Error handling

```dart
// ✅ Bien — deja que el repositorio lance ApiException
try {
  await repo.createAthlete(...);
  if (mounted) context.pop();
} catch (e) {
  setState(() => _error = e.toString());
}

// ❌ Evitar — silenciar errores
try { ... } catch (_) {}
```

---

## Convenciones de Commits

Formato: **Conventional Commits** ([spec](https://www.conventionalcommits.org/))

```
<type>(<scope>): <descripción corta>

[body opcional]

[footer opcional]
```

**Tipos:**

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Refactorización sin cambio de comportamiento |
| `test` | Añadir o corregir tests |
| `docs` | Solo documentación |
| `chore` | Mantenimiento, dependencias, CI |
| `perf` | Mejora de rendimiento |
| `style` | Formato de código (no lógica) |

**Scopes:** `athletes`, `attendance`, `auth`, `matches`, `tatami`, `techniques`, `academies`, `core`, `ci`, `deps`

**Ejemplos:**

```bash
feat(athletes): add profile photo upload
fix(tatami): prevent crash when preset list is empty
refactor(core): replace print with debugPrint in dio logger
test(auth): add JWT refresh interceptor unit tests
docs: add deployment guide for Firebase Hosting
chore(deps): update mobile_scanner to 6.x
```

---

## Testing

### Estructura de tests

```
test/
├── core/
│   ├── api/
│   │   ├── jwt_interceptor_test.dart
│   │   └── api_exception_test.dart
│   └── auth/
│       └── token_storage_test.dart
├── features/
│   ├── athletes/
│   │   ├── athletes_repository_test.dart
│   │   └── athletes_provider_test.dart
│   └── ...
├── shared/
│   └── models/
│       └── athlete_test.dart
└── helpers/
    ├── mock_dio.dart
    └── test_providers.dart
```

### Guía de escritura de tests

**Tests de Repository (con mock Dio):**

```dart
void main() {
  late AthletesRepository repo;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repo = AthletesRepository(dio: mockDio);
  });

  test('listAthletes returns paginated athletes', () async {
    when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
        .thenAnswer((_) async => Response(
              data: {/* ... */},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

    final result = await repo.listAthletes(academyId: 1);
    expect(result.results, isNotEmpty);
  });
}
```

**Tests de Provider (con ProviderContainer):**

```dart
void main() {
  test('athletesProvider returns data', () async {
    final container = ProviderContainer(
      overrides: [
        athletesRepositoryProvider.overrideWith((_) => FakeAthletesRepository()),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      athletesProvider(AthletesFilter(academyId: 1)).future,
    );
    expect(result.results, isNotEmpty);
  });
}
```

### Comandos

```bash
flutter test                          # Todos los tests
flutter test test/features/athletes/  # Solo athletes
flutter test --coverage               # Con coverage
```

---

## Proceso de PR

### Checklist antes de abrir un PR

- [ ] `flutter analyze` sin errores ni warnings
- [ ] `dart format --set-exit-if-changed lib/ test/` sin cambios pendientes
- [ ] `flutter test` todos los tests pasan
- [ ] El nombre del branch sigue la convención (`feat/`, `fix/`, etc.)
- [ ] Los commits siguen Conventional Commits
- [ ] Se han añadido tests para el nuevo comportamiento (si aplica)

### Template de descripción de PR

```markdown
## ¿Qué hace este PR?
Breve descripción de los cambios.

## Tipo de cambio
- [ ] Nueva funcionalidad
- [ ] Bug fix
- [ ] Refactorización
- [ ] Documentación

## Cómo testar
1. Paso 1
2. Paso 2

## Screenshots (si aplica)
```

### Reviewers

- Al menos **1 aprobación** para mergear a `main`
- El autor no puede aprobar su propio PR
- Usar **Squash and Merge** para mantener el historial limpio

---

## Añadir un Nuevo Feature

### Paso a paso

1. **Crear el modelo** en `lib/shared/models/nuevo_modelo.dart`

```dart
class NuevoModelo {
  const NuevoModelo({required this.id, required this.name});
  final int id;
  final String name;

  factory NuevoModelo.fromJson(Map<String, dynamic> json) => NuevoModelo(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

2. **Añadir constantes** en `lib/core/api/api_constants.dart`

```dart
static const String nuevoModeloPath = '/api/nuevo-modelo/';
```

3. **Crear el repository** en `lib/features/nuevo/data/nuevo_repository.dart`

```dart
class NuevoRepository {
  NuevoRepository({required this.dio});
  final Dio dio;

  Future<PaginatedResponse<NuevoModelo>> list({required int academyId}) async {
    final resp = await dio.get(ApiConstants.nuevoModeloPath,
        queryParameters: {ApiConstants.academyParam: academyId});
    return PaginatedResponse.fromJson(resp.data, NuevoModelo.fromJson);
  }
}
```

4. **Crear el provider** en `lib/features/nuevo/domain/nuevo_provider.dart`

```dart
final nuevoRepositoryProvider = Provider((ref) =>
    NuevoRepository(dio: ref.watch(dioProvider)));

final nuevoProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<NuevoModelo>, int>((ref, academyId) =>
        ref.watch(nuevoRepositoryProvider).list(academyId: academyId));
```

5. **Crear la screen** en `lib/features/nuevo/presentation/screens/nuevo_screen.dart`

6. **Registrar la ruta** en `lib/core/router/app_router.dart`

7. **Añadir entrada** en `MainShell` si necesita tab en bottom navigation

8. **Añadir strings** en `lib/core/theme/app_strings.dart`

9. **Escribir tests** en `test/features/nuevo/`
