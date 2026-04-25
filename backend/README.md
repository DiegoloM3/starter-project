# Firebase Backend — `symmetry-test-cf818`

Rules + schema para la colección `articles/` y el bucket `media/articles/`.
Todo lo que vive en esta carpeta se sube a Firebase con un solo
`firebase deploy` y representa el contrato de datos que consume el
frontend Flutter.

---

## Índice de documentos

| Archivo                             | Para qué sirve                                                                 |
|-------------------------------------|-------------------------------------------------------------------------------|
| [`docs/DB_SCHEMA.md`](./docs/DB_SCHEMA.md) | Especificación formal del documento `articles/{id}` (campos, tipos, ejemplo, diagrama). |
| [`docs/SCHEMA_RATIONALE.md`](./docs/SCHEMA_RATIONALE.md) | **Argumentación** del schema: por qué cada campo es como es, qué alternativas se descartaron. |
| [`docs/RULES_VISUAL.md`](./docs/RULES_VISUAL.md) | Guía visual para subir y validar reglas (diagramas de decisión, casos de prueba en el Playground). |
| [`firestore.rules`](./firestore.rules) | Reglas activas en Firestore.                                                  |
| [`storage.rules`](./storage.rules)   | Reglas activas en Cloud Storage.                                              |
| [`firestore.indexes.json`](./firestore.indexes.json) | Índices compuestos declarados explícitamente (los automáticos quedan en la consola). |
| [`firebase.json`](./firebase.json)   | Puntos de entrada para `firebase deploy` y el emulator suite.                 |
| [`.firebaserc`](./.firebaserc)       | Alias del proyecto activo (`symmetry-test-cf818`).                             |

---

## Deploy rápido de reglas

```bash
cd backend
firebase login --reauth                        # si el token expiró
firebase deploy --only firestore:rules,storage:rules
```

Salida esperada:

```
✔  cloud.firestore: rules file firestore.rules compiled successfully
✔  storage: rules file storage.rules compiled successfully
✔  Deploy complete!
```

**Antes de deployar cambios de reglas**, ejecutar las pruebas de
[`docs/RULES_VISUAL.md`](./docs/RULES_VISUAL.md) §3 y §5 para confirmar
que los casos críticos siguen verdes.

---

## Emuladores locales (opcional)

```bash
firebase emulators:start
```

- Firestore: `localhost:8080`
- Storage:   `localhost:9199`
- UI:        `localhost:4000`

El frontend ya está preparado para hablar con el proyecto real
(`symmetry-test-cf818`). Si se quisiera apuntar a los emuladores,
añadir `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080)`
en `bootstrap.dart` detrás de un flag `--dart-define=USE_EMULATORS=true`.
(No implementado: fuera del alcance de la prueba.)

---

## Flujo recomendado para cambiar una regla o el schema

1. Editar `firestore.rules` / `storage.rules` / `docs/DB_SCHEMA.md` en el repo.
2. Actualizar [`docs/SCHEMA_RATIONALE.md`](./docs/SCHEMA_RATIONALE.md) si el argumento
   detrás del cambio es relevante (casi siempre lo es).
3. Actualizar [`docs/RULES_VISUAL.md`](./docs/RULES_VISUAL.md) §6 (tabla maestra) y
   añadir casos de prueba §3/§5 si aplica.
4. `firebase deploy --only firestore:rules,storage:rules` (con `--dry-run` primero
   para validar sintaxis sin subir).
5. Reejecutar los casos de §3/§5 en la consola antes de merge.
