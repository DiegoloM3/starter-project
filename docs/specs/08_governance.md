# 08_GOVERNANCE.md

## 1. Purpose

Este documento define el modelo de gobernanza del ecosistema Symmetry:
cómo se toman decisiones sobre parámetros críticos del sistema.

La gobernanza **no es requisito del MVP**, pero debe diseñarse conceptualmente
para que la arquitectura técnica no la imposibilite en el futuro.

---

## 2. Principios de Gobernanza

### 2.1 Decisiones diferidas
Los parámetros más sensibles no se fijan al inicio.
Se reservan para cuando exista una comunidad suficientemente grande y diversa.

### 2.2 Resistencia a la concentración
El modelo 1 token = 1 voto es simple pero vulnerable a whales.
Se proponen mitigaciones (ver sección 5).

### 2.3 Transparencia auditable
Toda votación debe ser:
- pública antes de ejecutarse,
- trazable durante el proceso,
- y verificable tras el resultado.

---

## 3. Parámetros Gobernables

### 3.1 Tier 1 — Alta prioridad (decisiones que afectan la economía)
- Activación o no de tail emission
- Porcentaje de inflación si se activa
- Distribución del weekly pool (% por categoría de contribución)

### 3.2 Tier 2 — Prioridad media (afectan calidad del ecosistema)
- Pesos del read score
- Thresholds del fraud score
- Caps diarios y semanales de rewards
- Parámetros de reputación

### 3.3 Tier 3 — Baja prioridad (ajustes operativos)
- Políticas de moderación de contenido
- Reglas de promoción de artículos
- Parámetros de la advertising economy

---

## 4. Modelo de Votación

### 4.1 Quórum mínimo
Una votación es válida si participan al menos el **15% del supply circulante**.
Esto evita decisiones tomadas por una minoría activa.

### 4.2 Mayoría requerida
- Cambios Tier 1: mayoría cualificada (>66%)
- Cambios Tier 2: mayoría simple (>50%)
- Cambios Tier 3: mayoría simple (>50%)

### 4.3 Período de votación
- Propuesta pública: 7 días de discusión
- Votación activa: 7 días
- Implementación: 14 días tras aprobación (delay de seguridad)

---

## 5. Mitigaciones Anti-Concentración

### 5.1 Cuadratic voting (propuesta futura)
Cada token adicional tiene menos peso marginal.
Fórmula: `voto_efectivo = sqrt(tokens_en_juego)`

### 5.2 Lockup para votar
Solo pueden votar tokens que llevan >30 días sin moverse.
Reduce el impacto de compras masivas antes de una votación.

### 5.3 Veto comunitario
Si el 30% de los votantes activa un veto, la propuesta se detiene aunque haya mayoría.
Requiere análisis adicional antes de proceder.

---

## 6. Gobernanza de Tail Emission

Esta es la decisión más crítica del ecosistema.

### 6.1 Ventana de decisión
Durante los últimos 4 años del ciclo inicial de emisión se abre el proceso.

### 6.2 Opciones en votación
**Opción A:** Hard cap real en 110M. Sin emisión posterior.
- Sostenibilidad depende 100% de fees y sinks.

**Opción B:** Tail emission del 0.5% anual sobre el supply circulante.
- El término "max supply" se convierte en "initial supply cap".
- Inflación controlada y transparente.

**Opción C:** Tail emission gobernada dinámicamente cada 2 años.
- Mayor flexibilidad, mayor riesgo de manipulación.

### 6.3 Recomendación técnica
La opción A es la más segura para la credibilidad del token.
La opción B es defensible si la demanda real lo justifica.
La opción C se desaconseja por complejidad y riesgo de captura.

---

## 7. Implementación Técnica (Futuro)

La gobernanza en el MVP no requiere implementación on-chain.
Se puede implementar como:

1. **Fase 1 (MVP):** Encuesta firmada con tokens — off-chain, señalización.
2. **Fase 2:** Snapshot + multisig — decisiones reales con custodia.
3. **Fase 3:** Smart contract de gobernanza (si el token se tokeniza).

---

## 8. Risks

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Concentración de poder | Media | Alto | Quadratic voting, lockup |
| Baja participación | Alta | Medio | Incentivos por votar |
| Propuestas maliciosas | Baja | Alto | Delay de implementación |
| Gobernanza paralizada | Media | Medio | Quórum bajo Tier 3 |
