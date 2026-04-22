# 01_TOKENOMICS.md



## 1. Purpose



Este documento define el modelo económico del sistema propuesto para la aplicación de noticias.



⚠️ Importante:  

Esta capa **NO es requisito del assignment base**, pero se incluye como extensión ("overdelivery") alineada con los valores del proyecto:

- pensamiento crítico,

- diseño de sistemas,

- y propuesta de mejora del producto.



---



## 2. Design Principles



La tokenomics se diseña bajo los siguientes principios:



### 2.1 Anti-abuse first

El sistema no debe ser explotable mediante:

- bots,

- granjas de clics,

- consumo pasivo artificial.



### 2.2 Sustainable emission

La emisión debe:

- ser predecible,

- decreciente en el tiempo,

- y evitar shocks bruscos de oferta.



### 2.3 Real utility

El token debe tener usos reales dentro del sistema:

- visibilidad,

- promoción,

- features premium,

- participación en gobernanza futura.



### 2.4 Circular economy

El valor debe reciclarse dentro del sistema:

- anunciantes → gastan tokens  

- usuarios → reciben tokens por actividad válida  



---



## 3. Supply Model



### 3.1 Initial Supply



- **Max supply (pre-tail):** 110,000,000 tokens  

- **Premine total:** 10,000,000 tokens  



Distribución del premine:

- 5,000,000 → disponibles desde el inicio  

- 5,000,000 → bloqueados durante 24 meses  



### 3.2 Community Allocation



- **Supply destinado a usuarios:** 100,000,000 tokens  

- Distribución progresiva mediante emisión semanal  



---



## 4. Emission Model



### 4.1 Weekly Emission



Los tokens se distribuyen una vez por semana.



Cada ciclo semanal incluye:



- emisión nueva del protocolo  

- + redistribución de fees (publicidad, boosts, etc.)



### 4.2 Smooth Decay (Anti-shock)



En lugar de halvings abruptos, la emisión sigue una curva suave:



- equivalente a un halving cada 2 años  

- pero implementado como reducción progresiva semanal  



Esto evita:

- picos de oferta,

- shocks de mercado,

- comportamientos especulativos predecibles.



### 4.3 Emission Behavior



La emisión cumple:



- decreciente en el tiempo  

- continua (sin saltos)  

- auditable  

- determinista  



---



## 5. Distribution Logic



Cada semana se genera un pool de distribución:

weekly\_pool = emission + collected\_fees





### 5.1 Emission

Nuevos tokens creados según el modelo definido.



### 5.2 Fees

Tokens ya existentes que provienen de:

- publicidad

- promoción de contenido

- boosts



👉 Las fees **no aumentan el supply**, solo redistribuyen valor.



---



## 6. Reward Allocation



El pool semanal se reparte entre distintos tipos de contribución.



Distribución inicial sugerida:



- 55% → lectura verificada  

- 15% → comentarios útiles  

- 10% → feedback y moderación  

- 10% → diversidad de consumo  

- 10% → creación de contenido  



⚠️ Estos valores son ajustables en el tiempo.



---



## 7. Token Utility



El token se utiliza dentro del sistema para:



### 7.1 Promoción

- destacar artículos  

- aumentar visibilidad  



### 7.2 Publicidad

- compra de exposición  

- campañas segmentadas  



### 7.3 Features premium

- acceso a funciones avanzadas  

- análisis más profundos  



### 7.4 Futuro: Gobernanza

- votaciones sobre parámetros del sistema  

- decisiones económicas clave  



---



## 8. Tail Emission (Deferred Decision)



La emisión posterior al supply inicial no está definida desde el inicio.



### 8.1 Governance Window



Durante los últimos 4 años del ciclo inicial:



- se abrirá una votación  

- basada en stakeholding  



### 8.2 Voting Model



- 1 token = 1 voto  



### 8.3 Decision Scope



La comunidad decidirá:



- activar o no tail emission  

- porcentaje de inflación  

- reglas de distribución  



---



## 9. Risks



### 9.1 Inflation risk

Si la emisión supera la demanda:

→ pérdida de valor del token  



### 9.2 Abuse risk

Si el sistema de rewards es explotable:

→ colapso económico  



### 9.3 Governance risk

Modelo 1 token = 1 voto puede generar:

→ concentración de poder  



---



## 10. Scope Disclaimer



Este sistema económico:



- no es necesario para completar el assignment base  

- no se implementará completamente en el MVP  

- se propone como extensión conceptual y futura  



El foco principal del proyecto sigue siendo:

- backend funcional  

- frontend en Flutter  

- arquitectura limpia  

- y calidad de código  

