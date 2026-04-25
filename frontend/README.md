# 📰 Symmetry Daily News - Solución de Reto Técnico

Esta es la solución final para el reto técnico de **Daily News**. Se ha transformado el proyecto base en una aplicación robusta, siguiendo estándares de nivel producción y añadiendo funcionalidades avanzadas de Inteligencia Artificial.

---

## 🚀 Valor Agregado (Plus)

Para esta entrega, se implementaron las siguientes mejoras sobre los requerimientos base:

- **IA Image Generation**: Integración con OpenAI para generar automáticamente la imagen de portada de un artículo basándose en su título y descripción.
- **Firebase Storage Integration**: Las imágenes generadas se persisten en la nube para garantizar una carga rápida y consistente.
- **Custom Branding**: Se diseñó e implementó un Icono de Lanzador (Launcher Icon) adaptativo para iOS basado en la identidad visual de Symmetry.
- **UX Refinement**: Implementación de `PopScope` para navegación segura, estados de carga (Loading Indicators) y feedback mediante SnackBars.

---

## 🏗️ Arquitectura y Calidad de Código

Se ha seguido una estructura de **Clean Architecture** estricta, separando las responsabilidades en capas para garantizar que el código sea testeable y escalable:

- **Domain Layer**: Entidades y Casos de Uso (Lógica de negocio pura).
- **Data Layer**: Repositorios, Modelos de datos y Data Sources (Firebase, Floor, Remote API).
- **Presentation Layer**: Gestión de estados mediante **BLoC**, widgets modulares y vistas desacopladas.

**Inyección de Dependencias**: Administrada globalmente con `GetIt`.

---

## 🛠️ Stack Tecnológico

- **Framework**: Flutter
- **State Management**: BLoC (Business Logic Component)
- **Dependency Injection**: GetIt
- **Local Database**: Floor (SQLite)
- **Network**: Dio
- **Cloud Services**: Firebase Auth, Firestore, Storage & App Distribution.

---

## 📲 Entrega y QA (Testing)

Para facilitar la revisión por parte del equipo de Symmetry, la aplicación ha sido distribuida profesionalmente:

- **Plataforma**: iOS
- **Método de Distribución**: Firebase App Distribution.
- **Bundle ID**: `com.symmetry.antonio.arista`
- **Acceso**: Se ha enviado una invitación de prueba al correo de reclutamiento para su instalación inmediata en dispositivos físicos.

---

## ⚙️ Configuración del Proyecto

### Requisitos previos

1. Clonar el repositorio.
2. Asegurarse de tener el archivo `GoogleService-Info.plist` actualizado en `ios/Runner/`.

### Comandos útiles

**Instalar dependencias:**

```bash

### Generate files for routing, di etc.:
`flutter pub run build_runner build --delete-conflicting-outputs`
### Generate the icons:
`flutter pub run flutter_launcher_icons`
### Install the Project Dependencies (in pubsec.yaml)
`flutter pub get`
```
