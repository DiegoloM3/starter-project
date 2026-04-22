# 03_REWARD_ENGINE.md



## 1. Purpose



Este documento define cómo se transforman las acciones de los usuarios en recompensas dentro del sistema.



El objetivo es:



- premiar actividad real y útil,

- evitar abusos,

- y alinear incentivos con la calidad del ecosistema.

## 1.1 Estado de Implementación (Abril 2026)

- **Fase 1 (COMPLETADA)**:
    - Persistencia de `read_events` en MongoDB y transacciones de recompensa.
    - Sistema de reclamo básico con prevención de duplicados por `articleId`.
    - Integración en Frontend mediante `RewardCubit` y `BlocListener`.
- **Fase 2 (PLANIFICADA)**:
    - **Trust Multiplier**: Implementación del sistema de confianza basado en efecto de red (reputación acumulada).
    - **Scoring Layer**: Validación de lectura real mediante profundidad de scroll y tiempo activo.
    - **Anti-Fraud**: Heurísticas para detectar patrones mecánicos.

---

## 2. Core Principle



El sistema **NO recompensa directamente acciones simples** como:



- abrir un artículo,

- hacer scroll,

- permanecer tiempo en pantalla.



En su lugar, utiliza un **modelo basado en eventos + scoring**.



---



## 3. Architecture Overview



El sistema de rewards se basa en tres capas:



### 3.1 Event Layer

Registra eventos crudos del usuario:



- apertura de artículo

- scroll

- tiempo activo

- interacción

- comentarios

- feedback



---



### 3.2 Scoring Layer

Transforma eventos en métricas de calidad:



- read score

- engagement score

- trust score

- fraud score



---



### 3.3 Distribution Layer

Convierte los scores en tokens en el reparto semanal.



---



## 4. Event Model



Los eventos deben ser atómicos y trazables.



### Ejemplo:



```json

{

&#x20; "userId": "string",

&#x20; "articleId": "string",

&#x20; "eventType": "READ\_PROGRESS",

&#x20; "timestamp": "timestamp",

&#x20; "metadata": {

&#x20;   "scrollDepth": 0.65,

&#x20;   "activeTime": 42,

&#x20;   "interactionCount": 3

&#x20; }

}

5. Read Validation



Una lectura válida no es binaria. Se evalúa mediante un score.



5.1 Read Score (0 → 1)



Se calcula a partir de:



tiempo activo vs tiempo esperado

profundidad de scroll

interacción

consistencia del comportamiento

Ejemplo conceptual:

readScore =

&#x20; w1 \* timeScore +

&#x20; w2 \* scrollScore +

&#x20; w3 \* interactionScore

6. Quality Multipliers



El reward no depende solo de leer, sino de cómo se lee.



6.1 Engagement Multiplier

comentarios útiles

guardado

compartir

6.2 Diversity Multiplier

consumo de múltiples fuentes

evitar burbujas de contenido

6.3 Trust Multiplier

reputación del usuario

historial de comportamiento

7. Fraud Detection Layer



Cada usuario tiene un fraudScore.



Señales sospechosas:

patrones repetitivos

tiempo constante artificial

scroll lineal perfecto

sesiones excesivas

comportamiento no humano

Resultado:

if fraudScore > threshold:

&#x20;   reward = 0



o penalización progresiva.



8. Final Reward Formula



El reward final por usuario se basa en:



reward =

&#x20; baseReward

&#x20; \* readScore

&#x20; \* engagementMultiplier

&#x20; \* diversityMultiplier

&#x20; \* trustMultiplier

&#x20; \* (1 - fraudPenalty)

9. Weekly Distribution



El reparto no es inmediato.



Flujo:

se acumulan eventos durante la semana

se calculan scores por usuario

se calcula contribución relativa

se reparte el pool semanal proporcionalmente

10. Contribution Model



Cada usuario tiene un peso relativo:



userWeight = sum(validScores)



Distribución:



userReward = (userWeight / totalWeight) \* weeklyPool

11. Caps and Limits



Para evitar abuso:



11.1 Daily cap



Máximo de reward por día.



11.2 Diminishing returns



Menor recompensa si:



se consume demasiado contenido similar

se repite comportamiento

11.3 Per-article cap



Evita farmear un solo artículo.



12. Comment and Feedback Rewards



No todos los comentarios generan recompensa.



Requisitos:

longitud mínima

evaluación positiva de otros usuarios

ausencia de flags

Sistema sugerido:

votos de calidad

score de utilidad

13. Reputation System



Cada usuario tiene un score dinámico:



aumenta con actividad válida

disminuye con flags o fraude



Impacta en:



multiplicador de rewards

acceso a features

14. Storage Strategy



NO almacenar rewards directamente en artículos.



Separar:



Tables / Collections:

ReadEvents

UserScores

RewardDistributions

UserReputation

15. Anti-gaming Strategy



Principios clave:



no recompensar acciones triviales

evitar métricas fácilmente automatizables

introducir incertidumbre controlada

penalizar patrones mecánicos

16. Backend Execution



Scheduler semanal:



recoger eventos

calcular scores

detectar fraude

calcular pesos

repartir tokens

registrar transacciones

17. Transparency



El sistema debe ser:



parcialmente transparente (reglas generales)

pero no totalmente predecible (para evitar exploits)

18. Risks

18.1 Overfitting del sistema



Usuarios optimizan el comportamiento para maximizar rewards.



18.2 False positives



Usuarios legítimos penalizados.



18.3 Complexity



Demasiada complejidad dificulta mantenimiento.



19. MVP Scope



En el MVP:



usar reglas simplificadas

evitar ML complejo

implementar heurísticas básicas



Ejemplo:



tiempo mínimo + scroll mínimo = lectura válida

20. Scope Disclaimer



Este sistema:



es una extensión conceptual avanzada

no es requisito del assignment base

se puede implementar parcialmente como demo



El objetivo principal sigue siendo:



funcionalidad básica de la app

calidad de código

arquitectura limpia

