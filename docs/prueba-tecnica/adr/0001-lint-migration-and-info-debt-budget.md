# ADR-0001 — Migración de lints a `very_good_analysis` y presupuesto de deuda de infos

- **Fecha:** 2026-04-22
- **Estado:** Accepted
- **Fase:** F1 — Modernización técnica
- **Batches implicados:** B1.2 (+ B1.2b)

## Contexto

El proyecto arrancó con `flutter_lints ^1.0.0` (anterior a Dart 3) y SDK restringido a Dart 2.16. El [01_PLAN_FASES.md](../prueba-tecnica/01_PLAN_FASES.md) pide en F1 migrar a Dart 3 + `very_good_analysis ^6` con **`strict-casts`**, **`strict-inference`** y **`strict-raw-types`**, cubriendo las mejoras **R4** y **D8** del análisis arquitectónico.

La **Regla de oro por batch** del plan exige que cada commit compile y `flutter analyze` **pase** (sin issues). Al cambiar el perfil de lints en B1.2, `very_good_analysis` pasó a reportar **175 infos** (antes eran 8). Ninguno es error ni warning, pero por defecto `flutter analyze` sale con exit code 1 ante cualquier issue.

Arreglar todos los infos dentro del mismo batch B1.2 implicaría:
- Mezclar el cambio de tooling con refactors de código fuente no relacionados.
- Tocar archivos de features (`daily_news/**`) que ya están agendados para ser reescritos en F4, generando churn y merge conflicts internos.
- Inflar B1.2 muy por encima del umbral de ~300 líneas / 10 archivos que el plan declara como tope.

## Decisión

1. **B1.2** introduce los nuevos lints y los modos `strict-*` en `analysis_options.yaml`.
2. **B1.2b** (nuevo batch híbrido) aplica `dart fix --apply` para capturar las 121 correcciones seguras y automatizables (trailing commas, super params, package imports, directive ordering, constructor ordering, EOL, single quotes). Esto reduce los infos de **175 → 48**.
3. Los 48 infos residuales se tratan como **deuda contable** con dueño y fase de resolución explícitos:
   - `deprecated_member_use` (`withOpacity`) → F3 (design tokens) y F4 (refactor `daily_news`).
   - `cascade_invocations` en `injection_container.dart` → F2 (split de bootstrap + providers).
   - `prefer_null_aware_method_calls` en `article_tile.dart` → F4.
   - `flutter_style_todos` (1 ocurrencia) → F4.
   - `sort_pub_dependencies` (pubspec) → F9 (pulido final).
4. El **CI** configurado en B1.5 ejecuta `flutter analyze --fatal-warnings --no-fatal-infos`. La Regla de oro queda redefinida operativamente como:
   > *"Cada commit compila y no introduce ni errores ni warnings; los infos se permiten solo si tienen fase de resolución asignada."*
5. F9 cierra el ciclo: `flutter analyze` debe terminar **completamente limpio** (incluyendo infos) antes de entregar.

## Alternativas consideradas

| Opción | Descripción | Por qué no se eligió |
|---|---|---|
| **A. Estricto puro** | Deshacer B1.2 y rehacerlo con todas las correcciones incluidas en el mismo commit. | Viola el tope de tamaño del plan y mezcla tooling con refactor que ya tiene dueño en F4. |
| **B. Pragmática sin auto-fix** | Dejar B1.2 como está, 175 infos, y relajar el CI. | Deja 127 arreglos triviales sin resolver que degradan legibilidad por semanas y dan falsa sensación de estabilidad. |
| **C. Híbrida (elegida)** | B1.2 + B1.2b (`dart fix --apply`) + presupuesto explícito de deuda con dueño por fase + CI `--no-fatal-infos`. | Mantiene la granularidad del plan, rescata el 73% de los infos sin tocar F4 de forma prematura, y hace la deuda restante **visible y rastreable**. |

## Consecuencias

### Positivas
- La Regla de oro se respeta en su intención ("cada commit compila y no regresiona"): 0 errores, 0 warnings.
- Los 48 infos restantes tienen **dueño nominado** (fase + archivo); no son ruido perpetuo.
- Cambios masivos de estilo quedan aislados en **un único commit** (`style:`) — trivial de revisar, revertir o excluir con `git blame --ignore-revs-file`.
- El CI provee un *safety net* operativo sin bloquear el avance de las fases posteriores.

### Negativas / Riesgos
- Usar `--no-fatal-infos` puede enmascarar infos nuevos introducidos en fases futuras. **Mitigación:** F9 añade un paso explícito de "analyze totalmente limpio" como criterio de entrega.
- `dart fix --apply` añadió `dio: any` y `sqflite: any` a `pubspec.yaml` (regla `missing_dependency`). Son dependencias transitivas que el código ya usaba directamente; declararlas es correcto pero con constraints abiertas. **Mitigación:** F4 pinnea versiones específicas cuando refactorice los data sources.
- La redefinición de la Regla de oro ("sin errores ni warnings" en vez de "sin issues") es una concesión. Queda documentada aquí para que futuras fases sepan que **no es gratis**.

## Criterio de revisión

Este ADR se considera **superseded** cuando F9 termine con `flutter analyze` limpio al 100% (infos incluidos), punto en el que el CI puede endurecerse a `--fatal-infos` sin fricción. Crear entonces `ADR-XXXX — Endurecimiento definitivo de CI analyze` para cerrar el ciclo.

## Referencias

- **ADR panorámico:** [`ADR-0003 — Decisiones consolidadas`](./0003-decisiones-consolidadas.md) (este ADR aparece como D1 en su índice).
- Plan maestro: [`docs/prueba-tecnica/01_PLAN_FASES.md`](../prueba-tecnica/01_PLAN_FASES.md) — Fase 1 y sección *Plan de batches y commits*.
- Checklist: [`docs/prueba-tecnica/02_CHECKLIST.md`](../prueba-tecnica/02_CHECKLIST.md) — sección **G. Calidad de código**.
- Análisis arquitectónico: [`docs/prueba-tecnica/03_ANALISIS_ARQUITECTURA.md`](../prueba-tecnica/03_ANALISIS_ARQUITECTURA.md) — **R4**, **D8**.
- `very_good_analysis`: https://pub.dev/packages/very_good_analysis
