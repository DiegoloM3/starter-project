# 13_METRICS.md

## 1. Purpose

Este documento define qué métricas medir, cómo recogerlas y cómo usarlas
para tomar decisiones sobre el producto y el ecosistema.

---

## 2. Categorías de Métricas

### 2.1 Métricas de Producto (UX)
Miden la salud del producto como aplicación de noticias.

### 2.2 Métricas de Economía
Miden la salud del sistema de tokens y rewards.

### 2.3 Métricas de Contenido
Miden la calidad y diversidad del contenido.

### 2.4 Métricas de Seguridad
Miden la efectividad del sistema antifraude.

---

## 3. Métricas de Producto

| Métrica | Descripción | Objetivo MVP |
|---|---|---|
| DAU / MAU | Usuarios activos diarios / mensuales | — |
| Session length | Tiempo medio por sesión | > 4 minutos |
| Articles per session | Artículos abiertos por sesión | > 2 |
| Completion rate | % de artículos leídos hasta el final | > 35% |
| D1 retention | % usuarios que vuelven al día siguiente | > 40% |
| D7 retention | % usuarios activos a los 7 días | > 20% |
| Time to first article | Desde login hasta primer artículo abierto | < 3s |

---

## 4. Métricas de Economía

| Métrica | Descripción |
|---|---|
| Weekly emission | Tokens emitidos esa semana |
| Weekly fees | Tokens recaudados de publicidad y boosts |
| Active earners | Usuarios que recibieron tokens esa semana |
| Avg tokens per user | Media de tokens distribuidos por usuario activo |
| Gini coefficient | Concentración de tokens entre usuarios |
| Token velocity | Tokens gastados / tokens en circulación |

### 4.1 Alerta: desequilibrio de emisión
Si `weekly_emission / active_earners > 2x` la media histórica
→ revisar caps y thresholds.

---

## 5. Métricas de Contenido

| Métrica | Descripción |
|---|---|
| Articles published / week | Volumen de contenido nuevo |
| Category distribution | Diversidad de categorías |
| Source diversity | Número de fuentes distintas consumidas |
| Avg quality_score | Calidad media del contenido publicado |
| Read time accuracy | Diferencia entre `read_time` estimado y tiempo real |

---

## 6. Métricas de Seguridad

| Métrica | Descripción | Umbral de alerta |
|---|---|---|
| Flagged events / total | % de eventos marcados como sospechosos | > 5% |
| Users with fraud_score > 0.7 | Usuarios con alta sospecha | > 2% DAU |
| Repeated sessions | Sesiones con patrones mecánicos | > 10% |
| Impressions rejected | Impresiones publicitarias rechazadas por fraude | > 15% |

---

## 7. Data Collection

### 7.1 Eventos del cliente Flutter

El cliente envía eventos al backend en dos momentos:

**Batch al salir del artículo:**
```json
{
  "article_id": "string",
  "session_id": "string",
  "events": [
    { "type": "SCROLL", "depth": 0.3, "ts": 1714000010 },
    { "type": "SCROLL", "depth": 0.65, "ts": 1714000025 },
    { "type": "READ_PROGRESS", "active_time": 42, "ts": 1714000055 }
  ]
}
```

**Heartbeat cada 30s (para artículos largos):**
```json
{
  "article_id": "string",
  "session_id": "string",
  "active_time": 30
}
```

### 7.2 Almacenamiento

Los eventos se guardan en `read_events` (MongoDB).
Las métricas agregadas se calculan en el scheduler semanal.

---

## 8. Dashboard (Futuro)

Un dashboard interno con:
- Gráfico de DAU / MAU (30 días)
- Distribución semanal de tokens
- Tabla de top artículos por `verified_impressions`
- Alertas de fraude activas

En MVP: exportación CSV desde MongoDB con `mongosh`.

---

## 9. Privacy Considerations

- Los eventos de lectura no incluyen contenido del artículo leído
- Los `user_id` son anónimos internamente (UUID)
- No se recoge geolocalización en MVP
- Los eventos se agregan y los datos crudos se pueden purgar tras el epoch

---

## 10. MVP Scope

**Implementar:**
- Recogida de `READ_PROGRESS` y `ARTICLE_OPEN` desde Flutter
- Contador de `views` en artículos (increment en MongoDB)
- Índices para queries de agregación

**Diferir:**
- Dashboard visual
- Métricas de retención automatizadas
- Alertas de fraude en tiempo real
