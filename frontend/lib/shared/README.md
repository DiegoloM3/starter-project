# `shared/`

Arquetipo oficial de Symmetry (ver [`docs/APP_ARCHITECTURE.md`](../../../docs/APP_ARCHITECTURE.md)).

Contiene **código transversal con capa** (UI, servicios cross-feature, etc.) que no pertenece a una feature concreta pero sí tiene capas (presentation / domain / data). Se diferencia de `core/` en que `core/` agrupa utilidades **sin capas** (constants, logger, base `UseCase`, `Failure`, env).

Reglas:
- Nada aquí debe importar de `features/*/**`.
- Cualquier feature puede importar `shared/**` y `core/**`.
- Si un archivo solo tiene utilidades sin capas → va a `core/`, no aquí.

Esta carpeta se materializará con contenido real a medida que F3 (design system) y F7 (widgets reutilizables de `user_articles`) avancen.
