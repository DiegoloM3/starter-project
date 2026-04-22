# 06_LLM_RAG_SYSTEM.md



## 1. Purpose



Este documento define el uso de un sistema basado en LLM (Large Language Model) con RAG (Retrieval-Augmented Generation) para mejorar la comprensión de las noticias.



Este módulo es una **extensión avanzada (overdelivery)** y no es requisito del assignment base.



---



## 2. Objective



El sistema LLM no sustituye las noticias, sino que:



- ayuda a entenderlas mejor,

- proporciona contexto adicional,

- permite comparar múltiples fuentes,

- y reduce la fricción cognitiva del usuario.



---



## 3. Core Principles



### 3.1 Source-grounded responses

El modelo debe responder **basado en contenido real**, no inventado.



### 3.2 Transparency

Las respuestas deben indicar:

- de dónde proviene la información,

- qué artículos se han usado.



### 3.3 Non-authoritative stance

El sistema no debe presentarse como una fuente absoluta de verdad.



---



## 4. System Overview



El sistema se compone de:



1. Base de datos de artículos  

2. Sistema de embeddings  

3. Motor de recuperación (retrieval)  

4. LLM  

5. Interfaz de usuario  



---



## 5. RAG Pipeline



Flujo general:



``` id="x8k2rt"

User query

&#x20;  ↓

Embedding

&#x20;  ↓

Vector search

&#x20;  ↓

Relevant articles

&#x20;  ↓

Context assembly

&#x20;  ↓

LLM response

6. Data Preparation

6.1 Chunking



Los artículos se dividen en fragmentos:



tamaño recomendado: 300–800 tokens

mantener coherencia semántica

6.2 Embeddings



Cada fragmento se transforma en un vector:



usado para búsqueda semántica

almacenado en una vector DB

7. Retrieval Strategy

7.1 Top-K Search

recuperar los K fragmentos más relevantes

K típico: 3–8

7.2 Filtering



Opcional:



por fecha

por fuente

por categoría

8. Context Assembly



Los fragmentos recuperados se combinan en un contexto:



ordenados por relevancia

con referencia a su fuente

evitando redundancia

9. LLM Prompting



El prompt debe incluir:



contexto recuperado

instrucciones claras

formato de respuesta



Ejemplo conceptual:



Use only the provided context.

If the answer is not in the context, say so.

Cite sources when possible.

10. Output Format



Las respuestas deben:



ser claras

ser concisas

incluir referencias



Ejemplo:



resumen

puntos clave

fuentes utilizadas

11. Use Cases

11.1 Summarization



Resumen de un artículo o varios.



11.2 Cross-source comparison



Comparar cómo distintas fuentes cubren un tema.



11.3 Contextual Q\&A



Responder preguntas sobre una noticia.



11.4 Timeline generation



Explicar la evolución de un evento.



12. Bias Awareness (Optional)



El sistema puede señalar:



diferencias entre fuentes

énfasis distintos

posibles omisiones



⚠️ Sin afirmar “verdades absolutas”.



13. Limitations

13.1 Hallucinations



El modelo puede inventar información.



13.2 Context limits



El número de tokens es limitado.



13.3 Source dependency



La calidad depende del contenido disponible.



14. Mitigation Strategies

restringir respuestas al contexto

forzar citas

fallback cuando no hay datos suficientes



Ejemplo:



"I don't have enough information from the available articles."

15. Backend Architecture



Componentes:



embedding service

vector database

retrieval service

LLM API

16. Storage Options

Vector DB (opciones):

local (FAISS-like)

managed (Pinecone, etc.)

17. MVP Strategy



En el MVP:



Opción A (simple)

búsqueda por keywords

sin embeddings

Opción B (intermedia)

embeddings básicos

top-K retrieval

prompt simple

18. UI Integration



Posibles interfaces:



chatbot

botón "Ask about this article"

modo comparación

19. Risks

19.1 Over-reliance



Usuarios confían más en el bot que en la fuente.



19.2 Misinterpretation



Resúmenes incorrectos.



19.3 Performance



Coste y latencia de LLM.



20. Alignment with Assignment



Este módulo:



no es requerido

pero demuestra:

capacidad de aprendizaje

pensamiento de sistemas

integración de IA

21. Scope Disclaimer



Este sistema:



puede implementarse como prototipo

o solo documentarse



El foco principal sigue siendo:



funcionalidad base

arquitectura limpia

calidad de código

