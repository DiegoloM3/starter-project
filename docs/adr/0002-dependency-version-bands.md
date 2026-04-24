# ADR-0002 — Bandas de versión de dependencias de generación de código

- **Fecha:** 2026-04-22
- **Estado:** Accepted
- **Fase:** F1 — Modernización técnica
- **Batches implicados:** B1.3

## Contexto

La Fase 1 del [plan maestro](../prueba-tecnica/01_PLAN_FASES.md) pide agregar `freezed`, `json_serializable`, `dartz` y `go_router` como dependencias nucleares. El proyecto ya arrastra tres generadores (`retrofit_generator`, `floor_generator`, `build_runner`) que estaban pineados a versiones de 2021–2022.

El SDK activo es **Dart 3.10.4 / Flutter 3.38.5**. Esta combinación tiene dos particularidades que rompen resoluciones “obvias”:

1. **`_macros` eliminado del SDK.** Los bundles de `analyzer` en la franja `>=6.6.0 <7.3.0` dependen vía `macros` del paquete `_macros` que **ya no existe** en el SDK actual. Cualquier resolución que caiga en esa franja falla con `"could not find package _macros in the Dart SDK"`.
2. **APIs de `analyzer` movidas.** Los generadores nuevos (`retrofit_generator ^4.2`, `retrofit_generator ^8.x`, `freezed ^3.x`, `floor_generator ^1.5`) usan APIs `enclosingElement3`, `MixinOnClause`, `onClause`, `ExtensionDeclaration` que no existen en bandas viejas de `analyzer`, y los viejos (`retrofit_generator 3.0.1+1`, `dart_style 2.3.2`) usan APIs (`PostfixExpression`, `TokenType`) que ya desaparecieron.

El resultado es que la resolución por defecto queda en un *deadlock*: no existe una combinación libre de pins que satisfaga simultáneamente a `floor_generator`, `retrofit_generator` y `freezed`.

## Decisión

Se adopta un **corredor de compatibilidad** con pins explícitos en `dependencies`, `dev_dependencies` y `dependency_overrides`:

| Paquete | Pin | Razón |
|---|---|---|
| `retrofit` | `3.0.1` (exacto) | `retrofit_generator 3.0.1+1` depende de un constructor de `RestApi` con parámetro `autoCastResponse`, eliminado en `retrofit 3.0.2+1`. |
| `retrofit_generator` | `3.0.1+1` (exacto) | Única versión 3.x que compila sobre la banda de `analyzer` compatible con `floor_generator`. Versiones 4.x+ requieren `analyzer >=6.5`, lo que reabre el problema de `_macros`. |
| `floor_generator` | `^1.4.2` | Cualquier versión ≥ 1.5.0 reclama `source_gen ^1.5` o `analyzer ^6.4.1+`, saltando a la franja rota. |
| `build_runner` | `^2.4.13` | Necesario para que freezed pueda correr (la original `2.1.2` exige `build_config ^1.0.0 <1.1.0`, mientras freezed pide `^1.1.0`). |
| `freezed` | `^2.4.7` | Última 2.x estable antes de que la 2.5 empiece a depender de `analyzer >=6.5`. |
| `freezed_annotation` | `^2.4.4` | Alineado con `freezed 2.4`. |
| `json_serializable` | `^6.8.0` | Banda actual, compatible con el mismo `source_gen` que `freezed 2.4`. |
| `dart_style` (override) | `>=2.3.4 <2.3.7` | `dart_style 2.3.2` falla (APIs eliminadas); `dart_style 2.3.7+` requiere `analyzer 6.5+` (franja rota). |
| `analyzer` (override) | `>=6.4.1 <6.5.0` | Evita tanto la dependencia de `_macros` como los breakings entre APIs intermedias. |

Las **10 píldoras azules** (≈ 106 paquetes con versiones más modernas disponibles) se dejan intencionadamente sin bumpear: `flutter pub outdated` reporta rojo pero pin y paz.

## Alternativas consideradas

| Opción | Descripción | Por qué no se eligió |
|---|---|---|
| **A. Bump a freezed 3 + retrofit 4 + floor 1.5** | Ecosistema “moderno” alineado con `analyzer ^7.3`. | La banda 6.6–7.3 de `analyzer` depende del inexistente `_macros`; `analyzer ^7.3` no es alcanzable porque `floor_generator 1.4.x` lo bloquea con `source_gen ^1.x`. |
| **B. Quitar floor** | `floor_generator` es el nudo central. Reemplazar por `sqflite` directo o `drift`. | Rompe el cache local actual de `daily_news` fuera de alcance para F1 (refactor programado en F4). El criterio de salida de F1 es “no romper lo que ya funciona”. |
| **C. Esperar a que Dart/Flutter vuelvan a publicar `_macros`** | No hacer nada y esperar ecosistema. | Sin ETA oficial; bloquea el avance de F2–F9. |
| **D. Corredor de compatibilidad pineado** *(elegida)* | Fijar versiones exactas y `dependency_overrides` donde sea necesario. | Funcional, aislado, documentable y superable cuando F4 elimine `floor`/`retrofit` del camino. |

## Consecuencias

### Positivas
- `flutter pub get`, `flutter analyze` y `dart run build_runner build` corren de punta a punta sobre Dart 3.10.4.
- Cero errores/warnings de analyze (solo 49 infos bajo presupuesto ADR-0001).
- Los generadores existentes (`floor`, `retrofit`) siguen emitiendo código válido contra `.g.dart` ya committeados.

### Negativas / Riesgos
- El pin exacto de `retrofit: 3.0.1` y `retrofit_generator: 3.0.1+1` significa que **cualquier bump** rompe la resolución. F4 deberá liberar estos pins como parte del refactor de `daily_news`.
- Los `dependency_overrides` enmascaran versiones reales y pueden ocultar avisos de seguridad (CVE) en `analyzer` / `dart_style`. **Mitigación:** revisar el estado de `flutter pub outdated` en cada cierre de fase y en F9.
- Al NO adoptar `freezed 3`, el código no puede usar `sealed class` declarativo del propio `freezed` 3.x. Para F2 se usará la sintaxis `@freezed class ... with _$...` clásica, que funciona igual de bien con Dart 3 `sealed` keyword manual.
- `build_runner` bumpeó a 2.4, pero el resto del ecosistema 3.x-4.x sigue viejo. Incrementa la superficie de deprecations silenciosas.

## Plan de salida

Este ADR deja de ser necesario cuando alguna de estas tres cosas ocurra:

1. **F4 elimina `floor`** → libera el pin de `analyzer` y permite subir a `freezed 3 + retrofit 4 + analyzer ^7.3` sin conflicto.
2. **Dart publique de nuevo `_macros`** (u otra solución al decommission) → libera la banda 6.6–7.3 de `analyzer`.
3. **Se migre a `drift`** como reemplazo de `floor` (`floor_generator` queda fuera del árbol).

Cuando ocurra, crear `ADR-XXXX — Desbloqueo de bandas de dependencias post-F4` y eliminar los `dependency_overrides`.

## Referencias

- Plan maestro: [`docs/prueba-tecnica/01_PLAN_FASES.md`](../prueba-tecnica/01_PLAN_FASES.md) — F1 (tareas de deps) y F4 (refactor `daily_news`).
- ADR previo: [`ADR-0001`](./0001-lint-migration-and-info-debt-budget.md).
- Issue Dart macros: https://github.com/dart-lang/language/issues/1482 (discusión del decommission).
