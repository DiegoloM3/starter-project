# Architecture Decision Records (ADRs)

Registro de decisiones arquitectónicas y de proceso tomadas durante la prueba técnica de Symmetry. Cada ADR captura **qué** se decidió, **por qué**, qué **alternativas** se consideraron y las **consecuencias** aceptadas.

Formato inspirado en [Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) y [MADR](https://adr.github.io/madr/).

## Convenciones

- Nombre de archivo: `NNNN-kebab-case-title.md` (secuencia cronológica, empieza en `0001`).
- Estados: `Proposed`, `Accepted`, `Superseded by ADR-XXXX`, `Deprecated`.
- **Un ADR por decisión**. Si una decisión se revierte, se crea un nuevo ADR que supersede al anterior; el original se mantiene por trazabilidad.
- Vinculados al plan maestro en [`docs/prueba-tecnica/01_PLAN_FASES.md`](../prueba-tecnica/01_PLAN_FASES.md) y al checklist en [`docs/prueba-tecnica/02_CHECKLIST.md`](../prueba-tecnica/02_CHECKLIST.md).

## Índice

| ADR | Título | Estado | Fase |
|-----|--------|--------|------|
| [0001](./0001-lint-migration-and-info-debt-budget.md) | Migración de lints a `very_good_analysis` y presupuesto de deuda de infos | Accepted | F1 |
