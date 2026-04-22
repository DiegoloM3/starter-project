# ADR 001 — Prototipo REST + MongoDB vs port a Firestore

## Estado

Aceptado (2026-04-21).

## Contexto

El assignment original del repositorio usa **Firebase** (Firestore, Storage). Los specs en `Spec_workflows/` describen un backend **self-hosted** con **FastAPI**, **Motor**, **MongoDB** y **JWT**, alineado con [11_backend_architecture.md](Spec_workflows/11_backend_architecture.md) y [12_data_model.md](Spec_workflows/12_data_model.md).

La decisión de producto es: **implementar primero un prototipo sin Firebase** y **portar después** el mismo dominio a Firestore, reutilizando el cliente Flutter en capa de datos donde sea posible.

## Decisión

1. **Fase prototipo (actual)**  
   - API REST propia (FastAPI), persistencia en **MongoDB** (documentos compatibles semánticamente con el modelo descrito en el spec de datos).  
   - Autenticación **JWT** emitida por la API (no Firebase Auth en esta fase).  
   - El directorio **`backend/`** del repo sigue conteniendo solo configuración **Firebase** (rules, emulators) para el **port futuro**; el servicio Python vive en **`api/`** (raíz del repo).

2. **Fase port (posterior)**  
   - Mapear colecciones/documentos Mongo → **colecciones Firestore** y reglas de seguridad.  
   - Sustituir o alternar la implementación del **Data Layer** en Flutter: de cliente HTTP (`dio`) a **`cloud_firestore`** + **Storage** donde corresponda, manteniendo **domain** y **presentation** estables.  
   - Autenticación: alinear con Firebase Auth o mantener JWT detrás de Cloud Functions si se decide arquitectura híbrida (decisión en ADR posterior).

## Consecuencias

### Positivas

- Desarrollo local reproducible (Docker) sin depender del proyecto Firebase para iterar.  
- Contratos REST + esquema de documentos explícitos facilitan tests y revisión de código.  
- El modelo en [12_data_model.md](Spec_workflows/12_data_model.md) sirve como **fuente semántica** para ambas fases.

### Negativas / costes

- **Doble implementación** de la capa de datos (Mongo repo → Firestore repo): requiere disciplina para no diverger en reglas de negocio.  
- **Auth distinto** entre fases: migración de usuarios o re-registro debe planificarse antes del cutover.  
- Consultas: Mongo (aggregation, índices) vs Firestore (índices compuestos, límites de consulta) pueden exigir adaptadores.

## Mapeo conceptual (1:1 vs revisar en el port)

| Concepto | Prototipo (Mongo) | Port Firestore |
|----------|-------------------|----------------|
| Artículos | Colección `articles` | Colección `articles` (o subcolección bajo `users` según diseño final) |
| Usuarios | Colección `users` con `password_hash` | Documento usuario + **Firebase Auth** UID como clave estable |
| Eventos de lectura | Colección `read_events` (stub) | Colección o subcolección acorde a límites de escritura y reglas |
| Archivos / miniaturas | URL servida por API o almacenamiento local de dev | **Firebase Storage** + URL en documento |

## Alcance explícito fuera de este ADR

- Tokenomics on-chain, gobernanza avanzada, LLM/RAG completo y economía publicitaria no forman parte del criterio de aceptación del prototipo ni del port mínimo.

## Referencias

- [11_backend_architecture.md](Spec_workflows/11_backend_architecture.md)  
- [12_data_model.md](Spec_workflows/12_data_model.md)  
- [14_roadmap.md](Spec_workflows/14_roadmap.md)
