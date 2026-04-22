# Database Schema

This project has transitioned from Firebase Firestore to a custom **FastAPI + MongoDB** stack for enhanced flexibility and performance.

The official schema definition, including all collections (`articles`, `users`, `read_events`, etc.) and their fields, can be found in the technical specification:

👉 **[docs/specs/12_data_model.md](../specs/12_data_model.md)**

## Summary of Collections
- **articles**: Main content storage (replacing the ArticleSchema mentioned in root README).
- **users**: User profiles and authentication data.
- **read_events**: Tracking interactions for the rewards engine.
- **user_scores**: Aggregated performance metrics.

---
*Note: If you are using the Alternative Firebase Backend, please refer to [backend/README.md](../../backend/README.md).*
