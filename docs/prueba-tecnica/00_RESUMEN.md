# Resumen de la Prueba Técnica — Applicant Showcase App (Symmetry)

> Documento en español que sintetiza, con precisión, lo que la prueba exige. Sirve como punto de partida antes de abrir el plan de fases, el checklist o el análisis de arquitectura.

---

## 1. Contexto general

- **Proyecto:** `Applicant Showcase App`, propiedad de **Symmetry**.
- **Naturaleza:** Prueba técnica de selección para desarrolladores. No es un proyecto de producción; será revisado por desarrolladores senior de Symmetry.
- **Stack obligatorio:**
  - **Flutter** (frontend).
  - **Flutter BLoC / Cubit** (gestión de estado).
  - **Firebase** (backend): **Firestore**, **Cloud Storage** y **Local Emulator Suite**.
- **Arquitectura obligatoria:** adaptación de **Clean Architecture** descrita en [docs/APP_ARCHITECTURE.md](../APP_ARCHITECTURE.md), con 3 capas (`data`, `domain`, `presentation`) y reglas estrictas documentadas en [docs/ARCHITECTURE_VIOLATIONS.md](../ARCHITECTURE_VIOLATIONS.md).
- **Guía de código:** reglas de *Clean Code* en [docs/CODING_GUIDELINES.md](../CODING_GUIDELINES.md).
- **Valores a demostrar:** *Truth is King*, *Total Accountability*, *Maximally Overdeliver*.

---

## 2. Qué pide la prueba (en una frase)

> **Convertir la app de noticias existente en una app donde un "periodista" (usuario) pueda subir sus propios artículos a Firebase (Firestore + Cloud Storage), manteniendo la arquitectura Clean del proyecto y respetando el prototipo de Figma.**

---

## 3. Entregables concretos

### 3.1 Backend (Firebase)
1. **Diseñar el schema** del documento `Article` y cualquier colección/subcolección necesaria.
   - El `thumbnailURL` debe apuntar a un archivo en Cloud Storage dentro de `media/articles`.
   - Se escribe en [backend/docs/DB_SCHEMA.md](../../backend/docs/DB_SCHEMA.md) *(archivo a crear)*.
2. **Implementar el schema** en Firestore (colecciones, documentos, campos, índices si aplica).
3. **Enforzar el schema** con **Firestore Security Rules** en [backend/firestore.rules](../../backend/firestore.rules) y reglas de Storage en [backend/storage.rules](../../backend/storage.rules).
4. **Desplegar** mediante Firebase CLI (ver [backend/README.md](../../backend/README.md)).

### 3.2 Frontend (Flutter)
1. **Conectar Flutter con el proyecto Firebase** (archivo `firebase_options.dart`, `flutterfire configure`).
2. **Capa de dominio (`domain/`)** para la nueva funcionalidad de artículos del usuario:
   - Entidades, repositorios (interfaces), `params` y `use_cases`.
   - Inicialmente los use_cases devuelven **mock data** para poder construir la UI.
3. **Capa de presentación (`presentation/`)**:
   - BLoCs/Cubits que consumen los use_cases.
   - Pantallas convertidas desde el [prototipo de Figma](https://www.figma.com/file/EVpa82aUzPJuJfewjAA5ke/High-Fidelity-Prototype).
   - Widgets reutilizables.
4. **Capa de datos (`data/`)**:
   - `data_sources` para Firestore y Cloud Storage.
   - `models` que extienden las entidades.
   - `repository` que implementan las interfaces del dominio.
   - Sustituir los mocks del dominio por datos reales.
5. **Inyección de dependencias** (`get_it`) para registrar repos, data sources, use cases y blocs nuevos.

### 3.3 Reporte
- Escribir [docs/REPORT.md](../REPORT.md) siguiendo [REPORT_INSTRUCTIONS.md](../REPORT_INSTRUCTIONS.md).
- Debe incluir: introducción, aprendizaje, retos, reflexión, capturas/vídeos y sección de *overdelivery*.

### 3.4 Extra (opcional — pero fuertemente sugerido: "Maximally Overdeliver")
- Nueva funcionalidad más allá de subir artículos (autenticación, likes, comentarios, categorías, buscador, modo oscuro, etc.).
- Prototipos adicionales (UML, propuestas de UI, nuevas arquitecturas).
- Tests unitarios / de integración (TDD).
- Mejoras de UX/UI sobre el Figma.
- Propuestas de mejora sobre la arquitectura actual.

---

## 4. Restricciones arquitectónicas clave (no negociables)

| Capa | Puede importar de | **NO** puede |
|---|---|---|
| `data` | `domain`, `core`, `shared` | Importar `presentation` ni `use_cases`. Usar excepciones (no códigos de error) en data_sources. Solo los `repository` importan providers. |
| `domain` | **Nada** (puro Dart, sin Flutter) | Importar Flutter, Firebase o cualquier paquete externo. |
| `presentation` | `domain`, `core`, `shared` | Acceder a `data`/providers. Solo los `blocs/cubits` tocan `use_cases`. |

- Los `models` **siempre** extienden una `Entity` y exponen `fromRawData` / `toEntity()`.
- Los `repository` devuelven `DataState<T>` cuando hay llamada a red.
- Los `use_case` implementan un `call(params)` con **una sola** responsabilidad.

---

## 5. Criterios con los que Symmetry evaluará el trabajo

1. **Calidad de código** (Clean Code, nombres, funciones pequeñas, SRP).
2. **Experiencia demostrada** proporcional a la experiencia real del candidato.
3. **Cumplimiento funcional** (¿subir artículos funciona de punta a punta?).
4. **Alineación con los valores de Symmetry** (Truth, Accountability, Overdelivery).
5. **Respeto de la arquitectura** (violations = requests for changes).
6. **Claridad del reporte** y evidencia visual.

---

## 6. Documentos hermanos de este resumen

- [01_PLAN_FASES.md](./01_PLAN_FASES.md) — Plan integrado por fases (0–9) con mejoras arquitectónicas ya incorporadas.
- [02_CHECKLIST.md](./02_CHECKLIST.md) — Checklist de validación de estados/entregables.
- [03_ANALISIS_ARQUITECTURA.md](./03_ANALISIS_ARQUITECTURA.md) — Diagnóstico de la arquitectura actual y propuestas de mejora.
