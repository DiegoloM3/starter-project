# 05_CONTENT_PIPELINE.md



## 1. Purpose



Este documento define cómo se ingesta, procesa, almacena y sirve el contenido de noticias dentro de la aplicación.



Este módulo es **core para el assignment**, ya que:

- define el schema de artículos,
- conecta el contenido con el **almacén de documentos** usado en cada fase (ver 1.1),
- y soporta la funcionalidad principal del frontend.

## 1.1 Stack dual (prototipo REST + port a Firestore)

El assignment público del repositorio describe **Firebase Firestore**. En este fork, la decisión arquitectónica es:

1. **Fase prototipo:** persistencia en **MongoDB** detrás de una **API REST** (FastAPI + Motor + JWT). El contenido sigue el modelo semántico de [12_data_model.md](12_data_model.md).
2. **Fase port:** el mismo dominio se mapea a **Firestore** (y Firebase Storage para medios), con reglas y adaptadores en el Data Layer del cliente.

Referencia: [ADR 001 — Prototipo REST + MongoDB vs Firestore](../ADR_001_prototype_rest_mongo_vs_firestore.md).

En los diagramas de flujo de este documento, **“almacenamiento”** debe leerse como **MongoDB en prototipo** o **Firestore en port**, salvo que el párrafo indique explícitamente uno de los dos.

---

## 2. Pipeline Overview



El flujo de contenido sigue estas etapas:



1. Ingesta  

2. Normalización  

3. Enriquecimiento  

4. Almacenamiento (MongoDB en prototipo; Firestore tras el port)

5. Renderizado (Frontend)  



---



## 3. Content Sources



### 3.1 External APIs

- APIs de noticias (ej: NewsAPI-like)

- RSS feeds



### 3.2 Manual Input

- usuarios periodistas (feature principal del assignment)

- creación de artículos desde la app



---



## 4. Article Schema



Este schema está diseñado para:

- ser simple en MVP
- extensible a futuro
- compatible con **Firestore en el port** y con los documentos descritos para **MongoDB** en [12_data_model.md](12_data_model.md) durante el prototipo

**Notación legada (assignment Firebase):** el JSON siguiente usa nombres de campo estilo Firestore (`camelCase`, `timestamp`). En MongoDB los campos equivalentes suelen ser `snake_case` e `ISODate`; la API REST es la capa estable para el cliente móvil.



```json

{

&#x20; "id": "string",

&#x20; "author": "string",

&#x20; "title": "string",

&#x20; "description": "string",

&#x20; "content": "string",

&#x20; "source": "string",

&#x20; "category": "string",

&#x20; "url": "string",

&#x20; "thumbnailURL": "string",

&#x20; "publishedAt": "timestamp",

&#x20; "createdAt": "timestamp",

&#x20; "updatedAt": "timestamp",

&#x20; "views": 0,

&#x20; "readTime": 0,

&#x20; "tokensEarned": 0

}

5. Firestore Structure

Collection: articles



Cada documento representa un artículo:



articles/{articleId}

Subcollections (opcional futuro):

articles/{articleId}/comments

articles/{articleId}/metrics

6. Cloud Storage



Las imágenes no deben almacenarse en Firestore.



Regla:

almacenar imágenes en Firebase Cloud Storage

guardar solo la referencia (thumbnailURL)

Estructura sugerida:

media/articles/{articleId}/thumbnail.jpg

7. Normalization



Antes de guardar:



eliminar HTML innecesario

limpiar texto

asegurar encoding correcto

truncar descripciones

8. Enrichment



Campos derivados:



8.1 Read Time

readTime = wordCount / averageReadingSpeed



(aprox. 200-250 palabras/minuto)



8.2 Category Mapping

normalizar categorías externas

evitar duplicados ("Tech", "Technology", etc.)

9. AutoTEX Integration (Optional Advanced Feature)

Objetivo



Convertir contenido a formato LaTeX para:



presentación tipo newspaper

exportación a PDF

formato editorial consistente

Pipeline extendido:

raw content → cleaned content → LaTeX → rendered view

Notas

no es necesario para el MVP

puede implementarse como feature extra

10. Write Flow (User as Journalist)



Flujo principal del assignment:



usuario crea artículo

rellena campos:

título

contenido

categoría

imagen

imagen → Cloud Storage

datos → Firestore

artículo disponible en feed

11. Validation Rules



Antes de guardar:



título obligatorio

contenido mínimo

imagen válida

timestamps consistentes

12. Firestore Security Rules (Conceptual)



Ejemplo de reglas:



allow create: if request.auth != null

allow update: if request.auth.uid == resource.data.authorId

allow read: if true

13. Read Flow

usuario abre artículo

frontend obtiene documento de Firestore

renderiza contenido

registra eventos de lectura (para analytics/rewards)

14. Performance Considerations

14.1 Pagination

usar queries limitadas

evitar cargar todos los artículos

14.2 Indexing



Firestore indexes:



publishedAt

category

15. Caching Strategy



En frontend:



cache local de artículos

evitar llamadas repetidas

16. Future Extensions

versionado de artículos

edición colaborativa

sistema de drafts

etiquetas avanzadas

contenido multimedia

17. Risks

17.1 Data inconsistency



Errores en escritura concurrente.



17.2 Large documents



Firestore tiene límites de tamaño.



17.3 Image handling



Errores en subida o URLs rotas.



18. MVP Scope

Implementar:

colección articles

subida de imagen

creación de artículos

lectura desde Firestore

Opcional:

comments

metrics

AutoTEX

19. Alignment with Assignment



Este módulo cubre directamente:



diseño de schema

uso de Firestore

integración con Cloud Storage

funcionalidad principal solicitada

20. Scope Disclaimer



Este pipeline:



debe implementarse en versión simplificada

priorizando claridad y estabilidad



El foco sigue siendo:



arquitectura limpia

código mantenible

correcta integración frontend-backend

