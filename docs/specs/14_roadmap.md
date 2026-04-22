# 14_ROADMAP.md - Symmetry (InfoVeraz)

## 1. Vision
Symmetry evolucionará de un prototipo de lector a un ecosistema de información descentralizado y verificado por la red.

## 2. Roadmap General

### Q2 2026: Fase de Cimentación (EN CURSO)
- [x] **Migración Core**: Transición a FastAPI + MongoDB completada.
- [x] **Sistema de Recompensas Off-chain (Alpha)**: Implementado motor de reclamo con validación de tiempo (Scoring Layer v1).
- [x] **Refactorización Clean Code**: Aplicación de principios SOLID y segregación de interfaces.
- [x] **Capa de Depuración**: Registro estructurado en Backend y Frontend.
- [x] **Validación de Lectura**: Implementado timer de 10s en UI para reclamo automático.
- [ ] **Efecto de Red (Trust System)**: Implementación de multiplicadores por reputación.
- [ ] **Beta Pública**: Publicación de noticias verificada por agentes IA.

### Q3 2026: Expansión de Red
- [ ] **Motor de Scoring IA**: Heurísticas avanzadas (scroll depth) y detección de fraude.
- [ ] **Reputación Dinámica**: Sistema de badges y multiplicadores por historial.
- [ ] **Puente Blockchain**: Distribución on-chain de recompensas acumuladas (Testnet).

## 3. Estado de Capas Técnicas

### Data Layer
- [x] Esquemas de validación MongoDB (Calidad, Fraude, Épocas).
- [x] Repositorios desacoplados (Articles, Storage, Rewards).

### Rewards & Economy
- [x] API de Recompensas con validación de tiempo.
- [x] BLoC/Cubit de Recompensas con estados de carga y éxito.
- [ ] Lógica de multiplicadores por confianza (Trust Multiplier).
