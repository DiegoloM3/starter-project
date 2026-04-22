# 02_EMISSION_MODEL.md



## 1. Purpose



Este documento define el modelo matemático de emisión de tokens.



El objetivo principal es:



- evitar shocks de oferta,

- garantizar previsibilidad,

- y mantener una distribución justa a largo plazo.



---



## 2. Design Goal



El sistema busca replicar el comportamiento de un **halving cada 2 años**, pero sin saltos bruscos.



En lugar de usar reducciones discretas (tipo Bitcoin), se implementa un modelo de **decay continuo aproximado en pasos semanales**.



---



## 3. Time Model



- Unidad base: **semana**

- 1 año ≈ 52 semanas  

- 2 años ≈ 104 semanas  



---



## 4. Emission Function



La emisión semanal se define como:



**[

E(t) = E\_0 **cdot e^{-k t}

**]



donde:

- `E(t)` = emisión en la semana `t`

- `E0` = emisión inicial

- `k` = constante de decaimiento

- `t` = número de semanas desde el inicio



---



## 5. Halving Equivalence



Queremos que:



**[

E(104) = **frac{E\_0}{2}

**]



Por lo tanto:



:contentReference\[oaicite:0]{index=0}



Resolviendo:



**[

k = **frac{**ln(2)}{104} **approx 0.00666

**]



---



## 6. Initial Emission (E0)



Sabemos que el total a emitir es:



- 100,000,000 tokens (supply comunitario)



La suma total de la emisión continua es:



**[

**sum\_{t=0}^{**infty} E(t) **approx **int\_0^**infty E\_0 e^{-kt} dt = **frac{E\_0}{k}

**]



Por lo tanto:



:contentReference\[oaicite:1]{index=1}



Despejando:



**[

E\_0 = 100,000,000 **cdot k **approx 666,000 **text{ tokens/semana}

**]



---



## 7. Weekly Approximation



Como el sistema es discreto (semanal), usamos:



**[

E\_t = E\_0 **cdot e^{-k t}

**]



donde:

- `t` es entero (0, 1, 2, ...)



---



## 8. Emission Behavior Over Time



### Características:



- decrecimiento suave

- sin saltos abruptos

- convergente

- predecible



### Ejemplo aproximado:



- Semana 0 → \~666,000  

- Semana 104 → \~333,000  

- Semana 208 → \~166,000  

- Semana 312 → \~83,000  



---



## 9. Comparison with Halving Model



| Modelo            | Ventaja                     | Desventaja              |

|------------------|----------------------------|--------------------------|

| Halving discreto | Simple                     | Shock de oferta          |

| Decay continuo   | Suave y estable            | Más complejo de explicar |



---



## 10. Why Not Pure Poisson?



La distribución de Poisson:



- modela eventos discretos aleatorios,

- no es adecuada como función directa de emisión acumulativa.



Sin embargo, la intención original (evitar picos) se logra con:



- decay exponencial continuo,

- o micro-reducciones frecuentes.



---



## 11. Implementation Strategy



### Backend Scheduler



Cada semana:



1. calcular `t` (semana actual)

2. calcular emisión:



**[

E\_t = floor(E\_0 **cdot e^{-k t})

**]



3. añadir al pool semanal



---



## 12. Determinism



El modelo debe ser:



- reproducible

- auditable

- independiente del cliente



Por lo tanto:

- la emisión se calcula solo en backend

- no depende de inputs externos



---



## 13. Edge Cases



### 13.1 Rounding



- usar `floor()` para evitar sobreemisión

- acumular decimales si se desea precisión alta



### 13.2 End of Emission



Cuando la emisión tienda a 0:



- el sistema se sostendrá con fees  

- o se activará tail emission (si la gobernanza lo decide)



---



## 14. Future Adjustments



Parámetros potencialmente gobernables:



- `k` (ritmo de decay)

- `E0` (emisión inicial)

- duración efectiva del ciclo

- activación de tail emission



---



## 15. Scope Disclaimer



Este modelo:



- no es necesario para completar el assignment base  

- no será implementado completamente en el MVP  

- se documenta como extensión avanzada del sistema  



El foco del desarrollo inicial sigue siendo:



- arquitectura limpia  

- integración Firebase  

- frontend funcional  

