# 04_ANTIFRAUD.md



## 1. Purpose



Este documento define las estrategias para detectar, mitigar y prevenir abuso dentro del sistema.



El objetivo es:



- proteger la economía de tokens,

- garantizar recompensas justas,

- y evitar explotación mediante automatización o comportamiento no humano.

## 1.1 Modo degradado (Fase 1)

Antes de disponer de señales completas (heurísticas, dispositivo, reputación cruzada), el sistema puede operar en **modo mínimo**: rate limiting básico en API, validación de JWT, y almacenamiento de eventos para análisis posterior. Las secciones avanzadas de este documento aplican a fases posteriores. Ver [PHASE1_BACKLOG.md](../PHASE1_BACKLOG.md).

---

## 2. Threat Model



El sistema debe asumir que será atacado desde el primer día.



### 2.1 Tipos de abuso esperados



- bots leyendo artículos automáticamente  

- granjas de dispositivos  

- scripts de scroll automático  

- generación masiva de cuentas  

- spam de comentarios  

- manipulación de métricas de engagement  



---



## 3. Anti-Fraud Strategy Overview



El sistema se basa en 4 capas:



### 3.1 Detection

Identificar patrones sospechosos.



### 3.2 Scoring

Asignar un `fraudScore` a cada usuario.



### 3.3 Mitigation

Reducir o eliminar rewards.



### 3.4 Enforcement

Aplicar restricciones o penalizaciones.



---



## 4. Behavioral Analysis



El antifraude se basa principalmente en comportamiento.



### 4.1 Señales humanas típicas



- variación en tiempos de lectura  

- scroll no lineal  

- pausas naturales  

- interacción irregular  

- consumo diverso  



### 4.2 Señales artificiales



- tiempos constantes  

- scroll perfectamente lineal  

- patrones repetitivos  

- sesiones extremadamente largas o cortas  

- acciones sincronizadas entre cuentas  



---



## 5. Fraud Score



Cada usuario tiene un score dinámico:



``` id="n3f7ab"

fraudScore ∈ \[0, 1]

0 → comportamiento legítimo

1 → comportamiento claramente fraudulento

6. Detection Signals

6.1 Time Consistency



Usuarios con tiempos de lectura demasiado uniformes.



6.2 Scroll Pattern

lineal perfecto → sospechoso

sin pausas → sospechoso

6.3 Session Patterns

sesiones extremadamente frecuentes

sesiones idénticas

6.4 Interaction Entropy



Baja variabilidad en acciones → posible automatización.



6.5 Device Fingerprinting (opcional)

múltiples cuentas en un mismo dispositivo

uso de emuladores

7. Multi-Account Detection

Indicadores:

IP compartida

dispositivo compartido

comportamiento sincronizado

creación masiva de cuentas

Estrategias:

clustering de comportamiento

limitación por dispositivo

reputación compartida parcial

8. Reward Mitigation



El sistema no siempre bloquea directamente.



Estrategias progresivas:

if fraudScore > 0.9:

&#x20;   reward = 0

elif fraudScore > 0.7:

&#x20;   reward \*= 0.25

elif fraudScore > 0.5:

&#x20;   reward \*= 0.5

9. Shadow Penalties



Para evitar que los atacantes aprendan el sistema:



penalizaciones invisibles

rewards reducidos sin aviso

variabilidad en la respuesta

10. Rate Limiting

Límites sugeridos:

lecturas por minuto

artículos por hora

eventos por segundo



Ejemplo:



maxArticlesPerHour = 30

11. Comment Abuse Prevention

Reglas básicas:

longitud mínima

detección de repetición

filtrado de spam

Señales:

copy-paste masivo

baja diversidad léxica

alta frecuencia

12. Reputation Coupling



El fraude afecta la reputación.



Consecuencias:

menor multiplicador de rewards

limitación de acciones

pérdida de visibilidad

13. Cooldowns



Después de actividad intensa:



reducción temporal de rewards

limitación de interacción

14. Randomization



Introducir incertidumbre controlada:



pequeñas variaciones en rewards

thresholds dinámicos

selección parcial de eventos



Esto dificulta la ingeniería inversa del sistema.



15. Logging and Auditing



Todo debe ser trazable.



Logs clave:

eventos de usuario

scores calculados

rewards asignados

flags de fraude

16. Manual Review (Future)



Para casos críticos:



revisión manual

auditoría de cuentas

rollback de rewards

17. MVP Strategy



En el MVP:



Implementar:

thresholds simples

caps de uso

validación básica de lectura

No implementar aún:

modelos ML

clustering complejo

detección avanzada multi-dispositivo

18. Trade-offs

Seguridad vs UX



Demasiado control puede afectar usuarios legítimos.



Complejidad vs mantenimiento



Sistemas complejos son difíciles de mantener.



19. Risks

19.1 False positives



Usuarios reales penalizados.



19.2 Evasion



Atacantes adaptan su comportamiento.



19.3 Overengineering



Sistema demasiado complejo para MVP.



20. Guiding Principle



El sistema antifraude debe:



ser suficientemente robusto

pero iterativo

y mejorar con el tiempo

21. Scope Disclaimer



Este sistema:



es una extensión avanzada

no es requisito del assignment base

puede implementarse parcialmente como demo



El objetivo principal del proyecto sigue siendo:



backend funcional

frontend en Flutter

arquitectura limpia

calidad de código

