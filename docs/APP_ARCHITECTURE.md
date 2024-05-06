# Symmetry's App Architecture
Symmetry follows an adaptation of Clean Architecture, largely inspired on [this tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
Clean Architecture separates the software into layers with defined responsibilities.
More specifically, we divide the software in 3 layers: presentation, business logic, and data
layers. Each of these layers cover a specific functionality and have a specific set of
requirements, as explained [below](#clean-folders). 


## Folder Structure of the App
- lib
  - config 
    - routes
    - theme
  - core
    - constants
    - resources
    - usecase
  - shared
    - {feature}
      - data
        - data_sources
        - models
        - repository
      - domain
        - entities
        - repository
        - use_cases
      - presentation
        - bloc
        - screens
        - widgets
  - features
    - {feature}
      - data
        - data_sources
        - models
        - repository
      - domain
        - entities
        - use_cases
        - repository
      - presentation
        - bloc
        - screens
        - widgets

Furthermore, the **`test` folder directly mirrors the structure of the `lib` folder** with a {fileName}_test.dart extension on each file for each test.

## Clean Folders
All the functionality of our app will follow a clean structure, and when used, the 3 layers
together form a *clean folder* and they satisfy a set of very restrictive
conditions. The violations to this restrictions are technically explained [here](./ARCHITECTURE_VIOLATIONS.md)
### Clean Folder Requirements
1. A clean folder must follow a clean structure which is divided into 3 layers (represented as
folders in the database)
A. Data Layer
B. Domain Layer (Business Logic)
C. Presentation Layer (UI)
This is ALWAYS THE CASE, no exceptions
2. **Each layer can only communicate with the layer above or below it:**
- The Data Layer can only import from the Domain Layer
- The presentation layer can only import from the domain layer.
- The Domain Layer is a self-sustained layer with no imports from outer packages or folders in the app (it is written in pure dart).

#### Layer Requirements
##### Data Layer
- **Dependencies**: Relies exclusively on the Business Layer.
- **Structure**: Divided into three main components:
  1. **Data Sources**:
     - The sole classes in the codebase that interact with external services (e.g., APIs, LocalStorage, Cloud Storage, etc.).
     - Their functionalities are utilized by repository implementations for external data fetching.
  2. **Models**:
     - Extend entity classes from the Business Layer.
     - Responsible for parsing data from sources like APIs or Firestore into business objects, maintaining the same fields.
  3. **Repository Implementations**:
     - Fulfill the contracts (abstract classes) defined by the Business Layer's repositories.
     - Manage API/firebase/local storage interactions through the use of models.

##### Business Layer
- **Dependencies**: **Does not rely on any project dependencies** and is implemented purely in Dart (without Flutter packages).
- **Focus**: Solely concerned with business logic, abstracting away implementation details.
- **Structure**: Comprises three layers:
  1. **Entities**:
     - Define business objects used across the app for both data submission to APIs and data presentation in the UI.
     - Focused on implementing business logic without concerning data parsing (handled by Models) or UI presentation (handled by the Presentation Layer). Example: Age restrictions for users.
  2. **Params**
    - classes that represent the parameters of the use_cases - eg: SignInParams(String email, String password).
  3. **Use Cases**:
     - A piece of Business Logic that represents a single task the system needs to perform
     - Implements an abstract class with a `call` method, utilizing Repository Interfaces to execute specific functions. Examples include signup, login, upload_video, mark_read.
  4. **Repository Interfaces**:
     - Abstract classes that outline the necessary properties and methods for the application's features.
     - Imported by the use_cases (which are used in presentation) but implemented by the Data Layer, ensuring decoupling of business logic from specific APIs or UI design choices.


##### Presentation Layer
- **Dependencies**: Only interacts with the Business Layer, specifically with use cases.
- **Structure**: Organized into three folders:
  1. **Screens**
    - Contain the screens of the respective feature
  2. **Blocs**:
    - Contain blocs and cubits for state management in the UI.
    - Only these components import use cases to fulfill UI logic requirements.
  3. **Widgets**
    - contain the wigets specific to the respective feature

#### Exceptions
Apart from this, the data layer, business layer, and presentation layer can have imports from the `core` folder or `shared` folder (respecting the hierarchy; ie: presentation layer can never import from data layer).
