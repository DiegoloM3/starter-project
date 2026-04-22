# 07_BIAS_RELIABILITY.md



## 1. Purpose



Este documento define cómo evaluar y presentar:



- la fiabilidad de las fuentes,

- y posibles sesgos en la cobertura de noticias.



Este módulo es una **extensión avanzada (overdelivery)** y no es requisito del assignment base.



---



## 2. Objective



El objetivo NO es determinar una “verdad absoluta”, sino:



- proporcionar contexto adicional,

- ayudar al usuario a comparar fuentes,

- y reducir la formación de cámaras de eco.



---



## 3. Core Principles



### 3.1 No absolute truth score

No existe un único score que determine la verdad.



### 3.2 Multi-dimensional analysis

La evaluación se basa en múltiples factores.



### 3.3 Transparency

El usuario debe entender:

- por qué se muestra una señal,

- y qué significa.



---



## 4. Reliability Model



La fiabilidad se evalúa mediante varios ejes:



### 4.1 Source Transparency

- ¿la fuente identifica autores?

- ¿explica su metodología?



### 4.2 Citation Quality

- uso de fuentes primarias  

- enlaces verificables  



### 4.3 Correction History

- historial de correcciones  

- política editorial  



### 4.4 Content Type

- noticia vs opinión  

- análisis vs editorial  



---



## 5. Bias Model



El sesgo se analiza como **tendencias**, no como etiquetas absolutas.



### 5.1 Topic Framing

- qué aspectos se enfatizan  

- qué aspectos se omiten  



### 5.2 Language Tone

- lenguaje emocional  

- lenguaje neutral  



### 5.3 Source Diversity

- número de perspectivas citadas  

- homogeneidad ideológica  



---



## 6. Scoring Strategy



En lugar de un único valor:



``` id="v5r9qx"

reliability = {

&#x20; transparencyScore,

&#x20; citationScore,

&#x20; correctionScore,

&#x20; consistencyScore

}

bias = {

&#x20; framing,

&#x20; tone,

&#x20; diversity

}

7. UI Representation



El usuario no debe ver números sin contexto.



7.1 Suggested format

etiquetas explicativas

barras de nivel

descripciones cortas



Ejemplo:



“Alta transparencia editorial”

“Uso limitado de fuentes externas”

8. Article-Level vs Source-Level

8.1 Source-Level

reputación general del medio

8.2 Article-Level

calidad específica del artículo



Ambos deben coexistir.



9. Data Sources



Posibles inputs:



metadatos del artículo

análisis NLP

historial de la fuente

feedback de usuarios

10. LLM Integration



El sistema LLM puede:



explicar diferencias entre fuentes

resumir perspectivas

señalar contradicciones



⚠️ Siempre basado en contexto real (RAG).



11. Avoiding Misuse

Riesgos:

etiquetar fuentes como “buenas/malas”

imponer narrativa

simplificar en exceso

Mitigación:

lenguaje descriptivo, no absoluto

mostrar múltiples dimensiones

evitar juicios categóricos

12. Feedback Loop



Los usuarios pueden:



reportar contenido engañoso

señalar errores

valorar utilidad



Esto puede alimentar:



scores dinámicos

reputación de fuentes

13. Reputation Coupling



La fiabilidad impacta en:



visibilidad de artículos

ranking en el feed

acceso a promoción

14. Risks

14.1 Subjectivity



El sesgo no es completamente cuantificable.



14.2 Manipulation



Usuarios pueden intentar influir en scores.



14.3 Overcomplexity



Demasiada información puede confundir.



15. MVP Strategy



En el MVP:



Implementar:

etiquetas simples

diferenciación noticia vs opinión

No implementar aún:

scoring complejo

modelos NLP avanzados

16. Alignment with Assignment



Este módulo:



no es obligatorio

pero demuestra:

pensamiento crítico

diseño de sistemas

sensibilidad al problema real de noticias

17. Scope Disclaimer



Este sistema:



puede ser parcialmente implementado

o solo documentado



El foco principal sigue siendo:



funcionalidad base

arquitectura limpia

correcta implementación en Flutter + Firebase

