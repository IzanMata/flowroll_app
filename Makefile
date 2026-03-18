# FlowRoll — Makefile
# Uso: make <target>
# Requiere: Flutter SDK en PATH (o ajustar FLUTTER abajo)

FLUTTER := flutter
DART    := dart
ENV_FILE := .env

# URL por defecto para builds locales
API_URL ?= http://localhost:8000

.PHONY: help setup dev dev-android dev-web analyze format test test-coverage \
        build-apk build-appbundle build-ipa build-web clean doctor

## help: Muestra esta ayuda
help:
	@echo "FlowRoll — comandos disponibles:"
	@echo ""
	@sed -n 's/^## //p' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/  /'
	@echo ""

## setup: Instala dependencias
setup:
	$(FLUTTER) pub get

## doctor: Verifica el entorno Flutter
doctor:
	$(FLUTTER) doctor -v

## dev: Lanza la app en Chrome (web)
dev:
	$(FLUTTER) run -d chrome --dart-define-from-file=$(ENV_FILE)

## dev-android: Lanza la app en el primer dispositivo Android conectado
dev-android:
	$(FLUTTER) run -d $(shell $(FLUTTER) devices | grep android | head -1 | awk '{print $$2}') \
		--dart-define-from-file=$(ENV_FILE)

## dev-web: Lanza la app en web con hot reload
dev-web:
	$(FLUTTER) run -d web-server --web-port 8090 \
		--dart-define-from-file=$(ENV_FILE)

# ── Calidad de código ──────────────────────────────────────────────────────

## analyze: Analiza el código Dart
analyze:
	$(FLUTTER) analyze

## format: Formatea el código
format:
	$(DART) format lib/ test/

## format-check: Verifica formato sin modificar (para CI)
format-check:
	$(DART) format --set-exit-if-changed lib/ test/

## lint: Análisis + verificación de formato (para CI)
lint: format-check analyze

# ── Tests ──────────────────────────────────────────────────────────────────

## test: Ejecuta todos los tests
test:
	$(FLUTTER) test

## test-coverage: Tests con reporte de cobertura
test-coverage:
	$(FLUTTER) test --coverage
	@echo "Coverage report: coverage/lcov.info"
	@which genhtml > /dev/null 2>&1 && \
		genhtml coverage/lcov.info -o coverage/html && \
		echo "HTML report: coverage/html/index.html" || \
		echo "Instala lcov para el reporte HTML: brew install lcov"

## test-watch: Tests en modo watch (requiere fswatch)
test-watch:
	$(FLUTTER) test --watch

# ── Builds ─────────────────────────────────────────────────────────────────

## build-apk: Build APK debug
build-apk:
	$(FLUTTER) build apk --debug \
		--dart-define=API_BASE_URL=$(API_URL)

## build-apk-release: Build APK release (requiere keystore configurado)
build-apk-release:
	$(FLUTTER) build apk --release \
		--dart-define=API_BASE_URL=$(API_URL)

## build-appbundle: Build Android App Bundle para Play Store
build-appbundle:
	$(FLUTTER) build appbundle --release \
		--dart-define=API_BASE_URL=$(API_URL)

## build-ipa: Build iOS IPA (requiere macOS + Xcode)
build-ipa:
	$(FLUTTER) build ipa --release \
		--dart-define=API_BASE_URL=$(API_URL)

## build-web: Build web para producción
build-web:
	$(FLUTTER) build web --release \
		--dart-define=API_BASE_URL=$(API_URL) \
		--web-renderer canvaskit

## build-web-html: Build web con renderer HTML (más compatible, menor fidelidad)
build-web-html:
	$(FLUTTER) build web --release \
		--dart-define=API_BASE_URL=$(API_URL) \
		--web-renderer html

# ── Utilidades ─────────────────────────────────────────────────────────────

## clean: Limpia artefactos de build
clean:
	$(FLUTTER) clean
	rm -rf coverage/

## upgrade: Actualiza dependencias
upgrade:
	$(FLUTTER) pub upgrade

## outdated: Lista dependencias desactualizadas
outdated:
	$(FLUTTER) pub outdated

## devices: Lista dispositivos disponibles
devices:
	$(FLUTTER) devices

## icons: Genera iconos de la app (requiere flutter_launcher_icons)
icons:
	$(DART) run flutter_launcher_icons

## splash: Genera splash screen (requiere flutter_native_splash)
splash:
	$(DART) run flutter_native_splash:create
