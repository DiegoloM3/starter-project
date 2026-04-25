# =============================================================================
# Makefile — Atajos para builds, tests, deploys y operaciones frecuentes
# =============================================================================
#
# Uso: `make <target>`. Sin argumentos ejecuta `help`.
#
# Secretos:
#   Los valores reales de --dart-define viven en `frontend/keys.local.json`
#   (gitignoreado). La plantilla committeada está en `frontend/keys.json`.
#   Ejecuta `make keys` una vez para copiar la plantilla a `.local.json`
#   y luego reemplaza los placeholders con los valores reales. El resto de
#   targets (run, build-apk, build-appbundle, build-web) eligen el archivo
#   `.local.json` automáticamente cuando existe.
# =============================================================================

.DEFAULT_GOAL := help
.PHONY: help setup codegen keys analyze format format-fix test test-coverage \
        ci run run-release build-apk build-appbundle build-web \
        deploy-rules deploy-firestore deploy-storage deploy-all \
        emulators clean doctor grep-violations

# ---- Paths y variables -------------------------------------------------------

FRONTEND := frontend
BACKEND  := backend

# Plantilla committeada vs. copia local con secretos reales.
KEYS_TEMPLATE := keys.json
KEYS_LOCAL    := keys.local.json

# Selecciona keys.local.json si existe, si no keys.json. `shell` se evalúa al
# arrancar make, así que siempre estamos actualizados cuando se ejecuta un
# target.
KEYS_FILE := $(shell \
  if [ -f $(FRONTEND)/$(KEYS_LOCAL) ]; then \
    echo $(KEYS_LOCAL); \
  else \
    echo $(KEYS_TEMPLATE); \
  fi)

DART_DEFINE_FLAG := --dart-define-from-file=$(KEYS_FILE)

# ---- Help --------------------------------------------------------------------

help:  ## Muestra esta ayuda
	@echo "Symmetry — Makefile"
	@echo "=================="
	@echo ""
	@echo "Uso: make <target>"
	@echo ""
	@echo "Keys activo: $(FRONTEND)/$(KEYS_FILE)"
	@echo ""
	@echo "Targets disponibles:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

# ---- Setup -------------------------------------------------------------------

setup: ## Instala dependencias y ejecuta build_runner (primer arranque)
	cd $(FRONTEND) && flutter pub get
	cd $(FRONTEND) && flutter pub run build_runner build --delete-conflicting-outputs

codegen: ## Regenera archivos .g.dart y .freezed.dart
	cd $(FRONTEND) && flutter pub run build_runner build --delete-conflicting-outputs

keys: ## Crea frontend/keys.local.json desde el template si no existe
	@if [ -f $(FRONTEND)/$(KEYS_LOCAL) ]; then \
	  echo "✔  $(FRONTEND)/$(KEYS_LOCAL) ya existe, no se sobreescribe"; \
	else \
	  cp $(FRONTEND)/$(KEYS_TEMPLATE) $(FRONTEND)/$(KEYS_LOCAL); \
	  echo "✔  Creado $(FRONTEND)/$(KEYS_LOCAL) desde template"; \
	  echo "   Editalo con tu NEWS_API_KEY real antes de make run."; \
	fi

# ---- Calidad -----------------------------------------------------------------

analyze: ## Ejecuta flutter analyze (0 errors / 0 warnings esperado)
	cd $(FRONTEND) && flutter analyze

format: ## Valida formato sin modificar (fail si hay diffs — usado por CI)
	cd $(FRONTEND) && dart format --set-exit-if-changed .

format-fix: ## Aplica dart format escribiendo cambios
	cd $(FRONTEND) && dart format .

test: ## Ejecuta la suite completa (58/58 al día de hoy)
	cd $(FRONTEND) && flutter test

test-coverage: ## Corre tests generando coverage/lcov.info
	cd $(FRONTEND) && flutter test --coverage

ci: analyze format test ## Pipeline CI local: analyze + format + test
	@echo "✔  CI local verde"

# ---- Run / Build -------------------------------------------------------------

run: ## flutter run debug (usa keys.local.json si existe, si no keys.json)
	@echo "Usando $(FRONTEND)/$(KEYS_FILE) como --dart-define-from-file"
	cd $(FRONTEND) && flutter run $(DART_DEFINE_FLAG)

run-release: ## flutter run release (mismo manejo de keys)
	@echo "Usando $(FRONTEND)/$(KEYS_FILE) como --dart-define-from-file"
	cd $(FRONTEND) && flutter run --release $(DART_DEFINE_FLAG)

build-apk: ## Build APK release (salida: build/app/outputs/flutter-apk/)
	@echo "Usando $(FRONTEND)/$(KEYS_FILE) como --dart-define-from-file"
	cd $(FRONTEND) && flutter build apk --release $(DART_DEFINE_FLAG)

build-appbundle: ## Build AAB release para Google Play
	@echo "Usando $(FRONTEND)/$(KEYS_FILE) como --dart-define-from-file"
	cd $(FRONTEND) && flutter build appbundle --release $(DART_DEFINE_FLAG)

build-web: ## Build web release (salida: build/web/)
	@echo "Usando $(FRONTEND)/$(KEYS_FILE) como --dart-define-from-file"
	cd $(FRONTEND) && flutter build web --release $(DART_DEFINE_FLAG)

# ---- Firebase ----------------------------------------------------------------

deploy-rules: ## Deploy de firestore.rules + storage.rules al proyecto activo
	cd $(BACKEND) && firebase deploy --only firestore:rules,storage:rules

deploy-firestore: ## Deploy solo Firestore rules
	cd $(BACKEND) && firebase deploy --only firestore:rules

deploy-storage: ## Deploy solo Storage rules
	cd $(BACKEND) && firebase deploy --only storage:rules

deploy-all: ## Deploy completo (rules + indexes)
	cd $(BACKEND) && firebase deploy

emulators: ## Arranca Firestore + Storage emulators localmente
	cd $(BACKEND) && firebase emulators:start

# ---- Housekeeping ------------------------------------------------------------

clean: ## flutter clean + reinstala dependencias
	cd $(FRONTEND) && flutter clean
	cd $(FRONTEND) && flutter pub get

doctor: ## flutter doctor + versión de firebase-tools
	flutter doctor
	@firebase --version 2>/dev/null || echo "(firebase CLI no encontrado)"

grep-violations: ## Verifica los invariantes arquitectónicos con grep
	@echo "== domain/ sin imports prohibidos =="
	@! grep -RE "flutter|firebase_|dio|floor|cloud_firestore" $(FRONTEND)/lib/features/*/domain/ 2>/dev/null \
	  && echo "✔  limpio" || echo "✗  hay imports prohibidos en domain/"
	@echo "== presentation/ sin providers =="
	@! grep -RE "cloud_firestore|firebase_storage|floor|dio" $(FRONTEND)/lib/features/*/presentation/ 2>/dev/null \
	  && echo "✔  limpio" || echo "✗  hay providers en presentation/"
	@echo "== presentation/ sin cruzar a data/ =="
	@! grep -RE "features/.*/data/" $(FRONTEND)/lib/features/*/presentation/ 2>/dev/null \
	  && echo "✔  limpio" || echo "✗  presentation importa de data/"
	@echo "== sin DioError ni DataState residuales =="
	@! grep -RE "DioError|DataState" $(FRONTEND)/lib 2>/dev/null \
	  && echo "✔  limpio" || echo "✗  residuos encontrados"
