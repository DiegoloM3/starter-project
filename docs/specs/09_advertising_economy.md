# 09_ADVERTISING_ECONOMY.md

## 1. Purpose

Este documento define cómo funciona el modelo de publicidad dentro del ecosistema
y cómo conecta con la economía de tokens.

La publicidad es el principal **sink** del token y la principal fuente de fees
para redistribuir al pool semanal.

---

## 2. Principios

### 2.1 Publicidad como sink real
Los anunciantes gastan tokens para comprar exposición.
Esto genera demanda real del token y presión deflacionaria.

### 2.2 Fees redistribuidas, no quemadas
Los tokens gastados en publicidad **no se destruyen**.
Se redistribuyen al pool semanal como fees, manteniendo el supply circulante.

### 2.3 Alineación de incentivos
El anunciante quiere lectores atentos.
El usuario gana más tokens por leer con atención.
El sistema premia la misma cosa: lectura verificada.

---

## 3. Tipos de Publicidad

### 3.1 Artículo promovido (Promoted Article)
Un artículo de un creador aparece destacado en el feed.
- Coste: tokens por posición y duración
- Límite: máximo N artículos promovidos simultáneos por categoría

### 3.2 Banner contextual (Contextual Ad)
Anuncio insertado entre artículos según la categoría leída.
- Coste: tokens por 1000 impresiones verificadas (vCPM)
- Solo se cobra si el usuario vio el anuncio al menos 3 segundos

### 3.3 Boost de visibilidad
Un autor paga tokens para que su artículo aparezca más en el feed
sin etiqueta de "promovido".
- Límite de boost por artículo para no distorsionar la relevancia

---

## 4. Modelo de Precios

Los precios se expresan en tokens y son dinámicos:

```
precio_base = tokens_por_semana / demanda_estimada

precio_final = precio_base * (1 + competencia_por_categoría)
```

En el MVP los precios son fijos y gobernables:
- Artículo promovido: 500 tokens / 24h / categoría
- Banner vCPM: 50 tokens / 1000 impresiones verificadas
- Boost básico: 100 tokens / 48h

---

## 5. Verificación de Impresiones

Las impresiones publicitarias se verifican con el mismo sistema
que valida lecturas de artículos:

- El anuncio debe estar visible en pantalla
- Durante al menos 3 segundos (banners) o 5 segundos (artículos promovidos)
- Sin indicadores de bot activos

Solo se cobra al anunciante por impresiones verificadas (`verified_impressions`).

---

## 6. Flujo de Tokens

```
Anunciante deposita tokens
        ↓
Tokens van al smart contract / escrow del sistema
        ↓
Campaña ejecuta impresiones verificadas
        ↓
Tokens se liberan como fees recaudadas
        ↓
Al final de la semana: fees → weekly_pool
        ↓
Pool se redistribuye a usuarios activos
```

---

## 7. Data Model (MongoDB)

### Colección `ad_campaigns`

```json
{
  "_id": "ObjectId",
  "advertiser_id": "string",
  "campaign_type": "PROMOTED_ARTICLE | BANNER | BOOST",
  "target_article_id": "string | null",
  "target_categories": ["tecnología"],
  "budget_tokens": 1000,
  "spent_tokens": 342,
  "start_date": "ISODate",
  "end_date": "ISODate",
  "verified_impressions": 6840,
  "status": "ACTIVE | PAUSED | COMPLETED | CANCELLED",
  "created_at": "ISODate"
}
```

### Colección `ad_impressions`

```json
{
  "_id": "ObjectId",
  "campaign_id": "string",
  "user_id": "string",
  "article_id": "string | null",
  "timestamp": "ISODate",
  "view_duration_seconds": 4.8,
  "is_verified": true,
  "epoch": 12
}
```

---

## 8. Anti-Abuse en Publicidad

### 8.1 Protección del anunciante
- Solo se cobra por impresiones verificadas
- Usuarios con `fraud_score` alto no generan impresiones cobrables

### 8.2 Protección del usuario
- Límite de anuncios por sesión
- No se penaliza al usuario por ignorar un anuncio
- Los anuncios no bloquean la lectura del contenido

### 8.3 Protección del ecosistema
- No se permite auto-promoting abusivo (boost de artículos de baja calidad)
- Los artículos con `fraud_score` alto no pueden ser promovidos

---

## 9. MVP Scope

**Implementar:**
- Schema de `ad_campaigns` en MongoDB
- Endpoint para crear campaña (UI básica)
- Contador de impresiones verificadas

**Diferir:**
- Sistema de pujas dinámicas
- Targeting avanzado
- Dashboard de analytics para anunciantes
- Integración con el scheduler semanal de fees

---

## 10. Risks

| Riesgo | Mitigación |
|---|---|
| Inflación por fees bajas | Precio mínimo gobernado por la comunidad |
| Spam de anuncios de baja calidad | Moderación + mínimo de quality_score del artículo |
| Evasión de verificación | Mismo sistema de antifraude que lecturas |
| Demanda insuficiente de anunciantes | Fase 1: anunciantes internos (creadores boosteando su contenido) |
