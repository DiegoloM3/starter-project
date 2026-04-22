## 1. Vision

Este proyecto propone una aplicación de noticias para Android centrada en tres capas:

1. **Consumo de noticias con alta usabilidad**
2. **Comprensión asistida por IA**
3. **Economía de incentivos basada en atención verificada**

La aplicación no busca únicamente mostrar noticias, sino convertir la lectura, la interacción y la curación de contenido en actividades con valor dentro del ecosistema.

---

## 2. Core Product Hypothesis

La hipótesis principal es que una app de noticias puede mejorar si:

- recompensa la lectura real y no el simple scroll pasivo,
- incentiva interacciones útiles,
- reduce cámaras de eco mediante comparación de fuentes,
- ayuda a entender mejor el contexto con una LLM apoyada en RAG,
- y permite una economía interna sostenible basada en exposición publicitaria y emisión controlada.

---

## 3. Product Pillars

### 3.1 Content Layer
- Ingesta de noticias desde fuentes estructuradas.
- Normalización del contenido.
- Clasificación por tema, fuente y metadatos.
- Presentación limpia y optimizada para lectura.

### 3.2 Proof of Read Layer
- Detección de lectura activa.
- Métricas de permanencia, scroll y compromiso.
- Sistema de recompensa basado en señales de calidad.
- Prevención de abuso y automatización fraudulenta.

### 3.3 AI Layer
- Chatbot de consultas sobre noticias.
- RAG con contexto recuperado desde el corpus de artículos.
- Resúmenes, comparativas y contexto histórico.
- Señalización de posibles sesgos o diferencias de enfoque entre fuentes.

### 3.4 Token Economy Layer
- Emisión semanal controlada.
- Reparto de tokens en función de actividad verificada.
- Fees publicitarias redistribuidas al ecosistema.
- Gobernanza futura para decidir sobre tail emission y parámetros clave.

---

## 4. Tokenomics Overview

### 4.1 Supply
- Max supply pre-tail: **110,000,000 tokens**
- Premine del proyecto: **10,000,000 tokens**
  - **5,000,000 desbloqueados**
  - **5,000,000 bloqueados durante 2 años**
- Supply comunitario objetivo: **100,000,000 tokens**

### 4.2 Emission Model
La emisión se distribuye semanalmente con una curva suave equivalente a un halving cada 2 años, evitando shocks bruscos de oferta.

La emisión semanal debe:
- disminuir de forma predecible,
- ser fácil de auditar,
- y no generar picos artificiales de mercado.

### 4.3 Weekly Distribution
Cada semana se distribuye:

- emisión nueva del protocolo,
- más fees de tokens gastados en publicidad o boosts.

Las fees no se consideran nueva emisión, sino redistribución interna del valor capturado por el ecosistema.

### 4.4 Tail Emission Governance
La activación de una tail emission no se fija al inicio como regla inmutable.  
Se propone dejar esa decisión para una ventana de gobernanza durante los últimos 4 años del ciclo inicial.

La decisión se tomará mediante votación por stakeholding:
- **1 token = 1 voto**

---

## 5. Proof of Read Design

No se premiará únicamente el tiempo de pantalla.  
El sistema debe medir lectura real mediante un score compuesto con señales como:

- tiempo activo razonable,
- scroll natural,
- profundidad de lectura,
- interacción con el artículo,
- retorno posterior a la noticia,
- y variedad de consumo.

### Anti-abuse principles
- caps diarios o semanales,
- diminishing returns,
- score antifraude,
- reputación del usuario,
- penalización de patrones mecánicos o repetitivos.

---

## 6. Content Schema Strategy

El contenido de noticias se almacenará con una estructura base como la siguiente:

```json
{
  "author": "string",
  "title": "string",
  "description": "string",
  "url": "string",
  "urlToImage": "string",
  "publishedAt": "timestamp",
  "content": "string",
  "source": "string",
  "category": "string",
  "views": 0,
  "readTime": 0,
  "tokensEarned": 0
}
Notes
views y readTime se usarán como señales analíticas.
tokensEarned debe ser un valor derivado, no la fuente de verdad.
El sistema de rewards debe calcularse a partir de eventos de lectura y validación, no desde un campo manual.
Suggested future extensions
articleId
sourceId
qualityScore
fraudScore
rewardEpoch
verifiedImpressions
language
tags
7. AutoTEX and Editorial Rendering

El proyecto puede integrar AutoTEX para convertir contenido o documentos internos a LaTeX y renderizar el cuerpo de las noticias con una presentación editorial cuidada.

Esto permite:

estilos tipo newspaper,
vista limpia para lectura larga,
edición rápida de formato,
exportación a PDF o briefing,
y una identidad visual más sólida.
8. Governance and Community Decisions

La gobernanza de parámetros críticos se reservará para fases posteriores.

Temas potencialmente gobernables:

tail emission,
parámetros de reward,
pesos de scoring,
políticas de publicidad,
ajustes en reputación y moderación,
y reglas de promoción de contenido.

La gobernanza se diseñará cuidadosamente para evitar:

concentración excesiva de poder,
manipulación por grandes tenedores,
y votaciones que perjudiquen la calidad del ecosistema.
9. Risks and Open Questions
Key risks
granjas de lectura,
spam de comentarios,
inflación de tokens sin demanda real,
abuso de publicidad,
sesgo algorítmico,
y sobreconfianza en la LLM.
Open questions
¿Debe el token ser transferible desde el inicio?
¿Qué sinks garantizan demanda real?
¿Cómo se mide lectura auténtica con suficiente precisión?
¿Qué peso debe tener la reputación frente al volumen de actividad?
¿Cómo se muestra el bias de una fuente sin convertirlo en una falsa verdad absoluta?
10. MVP Scope
Must have
feed de noticias,
backend en Firestore,
schema de artículos,
frontend en Flutter,
estado con BLoC,
publicación/edición básica,
lectura limpia,
y documentación técnica.
Nice to have
chatbot con RAG,
score de fiabilidad,
reputación de usuario,
sistema de tokens,
y rendering editorial con AutoTEX.
11. Implementation Philosophy

La prioridad del proyecto es entregar una base sólida, limpia y ampliable.

El orden recomendado es:

schema de datos,
backend,
frontend funcional,
lógica de negocio,
documentación,
y después las capas avanzadas de tokenomics, IA y gobernanza.

El objetivo es construir un producto que pueda crecer sin rehacer la arquitectura central.