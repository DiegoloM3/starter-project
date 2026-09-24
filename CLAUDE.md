CLAUDE.md — Applicant Showcase App (Symmetry)

Este archivo es la referencia obligatoria para cualquier instancia de Claude (terminal/agente) que trabaje en este repositorio. Antes de escribir código, léelo completo. Ante cualquier duda entre este archivo y los documentos originales del proyecto (README.MD, AppArquitecture.md, ArquitectureViolations.md, CodingGuidelines.md, FRONTEND_BACKEND.md, BACKEND_README.MD, ReportInstructions.md), los documentos originales del repo tienen prioridad. Este CLAUDE.md es un resumen operativo, no un reemplazo.

1. Qué es este proyecto

Es un ejercicio de reclutamiento para Symmetry: una News App existente a la que se le debe añadir la funcionalidad de que un usuario (periodista) pueda subir sus propios artículos. El proyecto se evalúa por:

Calidad del código.
Nivel acorde a la experiencia del desarrollador.
Grado de cumplimiento (o superación) de la funcionalidad pedida.
Alineación con los 3 valores de Symmetry: Truth is King, Total Accountability, Maximally Overdeliver.

Consecuencia práctica: no basta con "que funcione". Cada decisión de diseño debe poder justificarse, y hay valor explícito en ir más allá de lo pedido (ver sección 7).

Stack: Flutter + Firebase (Firestore + Cloud Storage) + flutter_bloc, con Clean Architecture.

2. Arquitectura — fuente de verdad

La arquitectura oficial de este repo es la descrita en AppArquitecture.md. Se debe seguir esa estructura de carpetas y esas reglas de capas de forma estricta, sin excepciones:

lib/
config/        # routes, theme
core/          # constants, resources, usecase, shared
{feature}/
data/
data_sources/
models/
repository/
domain/
entities/
repository/
use_cases/
presentation/
bloc/
screens/
widgets/

test/ debe replicar exactamente esta estructura, con {fileName}_test.dart por cada archivo.

Las 3 capas (obligatorio, sin excepciones)
Data Layer: solo puede importar del Domain Layer.
Domain Layer: puro Dart, sin Flutter, sin imports de ningún otro módulo del proyecto.
Presentation Layer: solo puede importar del Domain Layer.

Ninguna capa puede saltarse a otra que no sea su vecina inmediata (la presentación nunca toca la data layer directamente, etc).

Nota sobre la referencia externa (video de Dev Branch)

Se usó como referencia conceptual adicional un resumen de la arquitectura Clean del canal Dev Branch (capas presentation/domain/data, DataState, inyección de dependencias con get_it, separación remote/local con Floor). Esta referencia NO sustituye AppArquitecture.md; solo aporta ideas complementarias donde el documento del proyecto no es explícito. Específicamente:

El wrapper DataState<Type> sí es obligatorio: está explícitamente exigido en ArquitectureViolations.md (regla 1.4.3) para las repository implementations al pedir datos a una API/Firestore.
La inyección de dependencias con get_it (Injection Container) se adopta como convención recomendada para este proyecto, ya que AppArquitecture.md no prohíbe ni impone un método de DI. Colocar el injection container en lib/config/ o lib/core/ (a decidir y documentar en el reporte si se hace).
La separación remote/local con Floor (SQLite) para persistencia local NO es un requisito de este proyecto (no hay mención de modo offline en el README). Solo considerarla si se implementa como parte de "overdelivery" (ej. cache offline de artículos), y en ese caso debe seguir viviendo dentro de data/data_sources/ como una fuente de datos local adicional, sin romper las capas.
Si en algún punto esta referencia entra en conflicto con AppArquitecture.md o ArquitectureViolations.md, gana siempre el documento del proyecto.
3. Reglas de violación de arquitectura (checklist obligatorio antes de cada commit)

Basado en ArquitectureViolations.md. Revisar SIEMPRE antes de dar por terminado un archivo:

Data Layer

Nunca importa desde presentation/.
Nunca importa use_cases.
data_sources/: únicas clases que tocan APIs/Firestore/Cloud Storage/hardware/local storage. Lanzan excepciones, nunca error codes ni "failure objects".
models/: SIEMPRE extienden una entity de domain/entities. Incluyen toEntity() y un factory fromRawData.
repository/: implementaciones nombradas {RepositoryInterfaceName}Impl. Solo implementan interfaces de domain/repository. SIEMPRE retornan DataState<Type> al pedir datos externos. Único lugar que importa data_providers.

Domain Layer

Cero imports de otros módulos del proyecto (solo librerías Dart puras).
entities/: sin lógica de fetching ni de presentación, solo lógica de negocio.
use_cases/: cada uno implementa UNA sola operación. Nunca interactúan directo con la data layer, solo vía repository interfaces.
repository/ (interfaces): abstract classes sin implementación. Nunca retornan models, siempre entities.

Presentation Layer

Nunca accede directo a la data layer ni a providers.
Blocs/Cubits: solo estado de UI, sin lógica de negocio. Son el ÚNICO punto de interacción con use_cases.
Screens: delegan lógica a blocs/use_cases, no dependen directo de models.
Widgets: reutilizables, sin lógica de negocio propia, reciben datos por constructor/estado.

Cualquier violación de estas reglas = PR rechazado (aplicado por uno mismo como reviewer).

4. Guías de código (CodingGuidelines.md)

Aplicar en todo commit:

CG1 — Boy Scout Rule: si tocas código sin tests, agrégalos. Si ves código refactorizable al pasar, refactóralo.
CG2 — Nombres significativos: seguir convenciones ya establecidas por tipo de archivo (use_cases, {X}Impl, entities...). Nombres que revelen intención, sin desinformación, pronunciables. Clases = sustantivos, funciones = verbos.
CG3 — Funciones pequeñas: máximo 2 niveles de anidamiento, SRP estricto, nombres descriptivos largos > comentarios, máximo ~2-3 argumentos, separación comando/query (una función o cambia estado o retorna info, no ambas).
CG4 — TDD cuando sea posible: no es obligatorio para este proyecto salvo que se busque overdelivery, pero si se escribe test-first, documentarlo en el reporte.
CG5 — Clases pequeñas: una responsabilidad, pocas variables de instancia.
CG6 — Abstracción para aislar cambios: usar abstract classes/interfaces donde el detalle concreto pueda cambiar (ya cubierto en gran parte por el patrón repository).
5. Flujo de trabajo esperado (orden de implementación)

Seguir el orden del README, no saltarse pasos:

Backend (Firestore)
Diseñar el schema de Article (inspirado en los datos reales que ya consume la app desde su API actual). Debe incluir thumbnailURL apuntando a Cloud Storage, carpeta media/articles. Documentar en backend/docs/DB_SCHEMA.md.
Implementar colecciones/documentos en Firestore.
Escribir y desplegar backend/firestore.rules que enforcen ese schema (ver backend/README.md para el proceso de deploy).
Setup Frontend-Backend: conectar Flutter con el proyecto Firebase (FlutterFire, firebase_options.dart).
Domain Layer de la nueva feature (subir artículos): entities, params, use_cases, repository interfaces. Los use_cases deben usar datos mock en esta etapa, aún sin tocar Firebase real.
Presentation Layer: Blocs/Cubits que consumen los use_cases (con mocks), y las screens/widgets según el prototipo de Figma referenciado en el README. Las anotaciones del Figma son pistas de overdelivery, no ruido.
Data Layer: reemplazar los mocks. data_sources (Firestore/Storage), models (extendiendo entities, con fromRawData/toEntity()), repository impl ({Interface}Impl, retornando DataState<Type>).
Tests: unitarios mínimos en use_cases críticos; agregar tests a lo que se toque sin cobertura previa (Boy Scout).
Auditoría propia: repasar el propio código contra la sección 3 de este archivo como si fueras el reviewer senior.
Reporte (/docs/REPORT.md): seguir ReportInstructions.md al pie de la letra (introducción, proceso de aprendizaje, retos, reflexión, evidencia con capturas/video, overdelivery, secciones extra).

No adelantar UI sin haber terminado el domain layer con mocks — el README lo desaconseja explícitamente.

6. Comandos útiles del proyecto
   bash
# Generar rutas, DI, etc.
flutter pub run build_runner build --delete-conflicting-outputs

# Generar íconos de la app
flutter pub run flutter_launcher_icons

# Instalar dependencias
flutter pub get

# Firebase CLI (backend)
npm install -g firebase-tools
firebase login
firebase init      # elegir: emulators, firestore, cloud storage
firebase deploy    # sube firestore.rules — CUIDADO: sobreescribe reglas existentes

# Emuladores locales
firebase emulators:start
7. Overdelivery — dónde tiene sentido invertir tiempo extra

El README pondera explícitamente ir más allá de lo pedido. Ideas alineadas con la arquitectura ya definida (no inventar una paralela):

CRUD completo de artículos (editar/borrar), no solo creación.
Borradores (draft status en el schema).
Búsqueda/filtros sobre artículos propios.
Cache/persistencia local como fuente de datos adicional dentro de data/data_sources/ (inspirado en el patrón remote/local del video de referencia), documentando explícitamente que es una extensión sobre AppArquitecture.md, no parte de su base.
Mejoras de UI/UX o animaciones sobre el Figma original.
Documentar cualquier decisión que se desvíe de lo sugerido en el README (schema, tecnología, arquitectura) — el valor "Truth is King" pesa tanto como el código.

Todo overdelivery debe documentarse en /docs/REPORT.md, sección 6, con: qué se hizo, por qué, y cómo probarlo/demoarlo.

8. Reglas para el agente de Claude Code al trabajar aquí
   Nunca generar código que viole la sección 3 de este archivo. Si una solicitud del usuario lo requeriría, señalarlo explícitamente antes de implementar.
   Antes de crear un archivo nuevo, verificar en qué capa/carpeta corresponde según la sección 2.
   Preferir extender el patrón ya existente en el código (naming, estructura de entities/use_cases) antes que introducir uno nuevo.
   Si se necesita una decisión no cubierta por AppArquitecture.md (ej. cómo estructurar DI), usar la referencia del video como apoyo, pero dejar constancia en el reporte de que es una decisión propia y por qué.
   Cada nueva funcionalidad de negocio = mínimo: 1 entity (si aplica), 1+ use_case, 1 repository interface + su impl, actualización de bloc/cubit correspondiente. No saltarse capas "por rapidez".
   Al tocar código legacy sin tests, añadirlos (Boy Scout Rule, CG1).
   **IMPORTANTE: Todo el código, comentarios, nombres de variables, y documentación debe estar en INGLÉS.** Esto incluye: nombres de funciones/clases, comentarios de código, commits de git, documentación en Markdown, nombres de archivos (excepto archivos de documentación específicos del proyecto). No mezclar español e inglés.