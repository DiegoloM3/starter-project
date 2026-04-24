# Architecture Decision Records (ADRs)

Registro de decisiones arquitectónicas y de proceso tomadas durante la prueba técnica de Symmetry. Cada ADR captura **qué** se decidió, **por qué**, qué **alternativas** se consideraron y las **consecuencias** aceptadas.

Formato inspirado en [Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) y [MADR](https://adr.github.io/madr/).

## Cómo leer este directorio

- **Si solo lees uno, lee [ADR-0003](./0003-decisiones-consolidadas.md).** Es la fuente de verdad panorámica: 14 decisiones resumidas con sus trade-offs y referencias cruzadas.
- ADR-0001 y ADR-0002 son profundizaciones de dos decisiones locales (lints e ecosistema de dependencias). Son autocontenidos y no han sido superseded.
- Para la narrativa de implementación (cómo se construyó cada pieza, no solo qué se decidió) ver [`docs/SOLUCION.md`](../SOLUCION.md).

## Convenciones

- Nombre de archivo: `NNNN-kebab-case-title.md` (secuencia cronológica, empieza en `0001`).
- Estados: `Proposed`, `Accepted`, `Superseded by ADR-XXXX`, `Deprecated`.
- **Un ADR por decisión**. Si una decisión se revierte, se crea un nuevo ADR que supersede al anterior; el original se mantiene por trazabilidad.
- Vinculados al plan maestro en [`docs/prueba-tecnica/01_PLAN_FASES.md`](../prueba-tecnica/01_PLAN_FASES.md) y al checklist en [`docs/prueba-tecnica/02_CHECKLIST.md`](../prueba-tecnica/02_CHECKLIST.md).

## Índice

| ADR | Título | Alcance | Estado | Fase |
|-----|--------|---------|--------|------|
| [0001](./0001-lint-migration-and-info-debt-budget.md) | Migración de lints a `very_good_analysis` y presupuesto de deuda de infos | Local | Accepted | F1 |
| [0002](./0002-dependency-version-bands.md) | Bandas de versión de dependencias de generación de código | Local | Accepted | F1 |
| [0003](./0003-decisiones-consolidadas.md) | **Decisiones técnicas consolidadas (fuente de verdad)** | Panorámico — F0…F9 | Accepted | F0–F9 |

## Mapa temático rápido

| Tema                                      | Dónde se documenta                                                              |
|-------------------------------------------|---------------------------------------------------------------------------------|
| Lints, `strict-casts`, info debt          | [ADR-0001](./0001-lint-migration-and-info-debt-budget.md)                       |
| Pins de `analyzer`/`dart_style`/`floor`   | [ADR-0002](./0002-dependency-version-bands.md)                                  |
| Error handling con `Either<AppFailure, T>`| [ADR-0003 §4](./0003-decisiones-consolidadas.md#4-d3-d4-d5--contrato-universal-de-errores) |
| Bootstrap separado + handlers globales    | [ADR-0003 §5](./0003-decisiones-consolidadas.md#5-d6--bootstrap-separado-y-handlers-globales-de-error) |
| Design tokens + `ThemeExtension`          | [ADR-0003 §6](./0003-decisiones-consolidadas.md#6-d7--design-tokens--themeextension) |
| Router `go_router` tipado                 | [ADR-0003 §7](./0003-decisiones-consolidadas.md#7-d8--router-declarativo-con-go_router) |
| `freezed` / `json_serializable`           | [ADR-0003 §8](./0003-decisiones-consolidadas.md#8-d9--freezed--json_serializable) |
| Schema + reglas Firestore/Storage         | [ADR-0003 §9](./0003-decisiones-consolidadas.md#9-d10--esquema-reglas-y-paths) |
| Fake repository en `data/fake/`           | [ADR-0003 §10](./0003-decisiones-consolidadas.md#10-d11--fake-repository-en-datafake) |
| Ports `AuthSession` / `ThumbnailPickerService` | [ADR-0003 §11](./0003-decisiones-consolidadas.md#11-d12--ports-con-stubs-authsession-y-thumbnailpickerservice) |
| DI condicional (`Firebase.apps.isNotEmpty`)| [ADR-0003 §12](./0003-decisiones-consolidadas.md#12-d13--di-condicional-firebaseappsisnotempty) |
| Article id client-side                    | [ADR-0003 §13](./0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side) |
| Criterios verificados por grep            | [ADR-0003 §14](./0003-decisiones-consolidadas.md#14-criterios-arquitectónicos-verificados) |
