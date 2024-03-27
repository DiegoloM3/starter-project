# Architecture Violations

This is a document with the specific architecture violations to be avoided in our codebase. These violations will be checked by code reviewers (in this case yourselves) and will result in the rejection of a pull request, and request for changes in any pull request which contains them.

1. **Data Layer Violations**
    - **1.1 General**
        - 1.1.1 Never import from any presentation layer
        - 1.1.2 Do not import use_cases
    - **1.2 data_sources**
        - 1.2.1 Throw exceptions from here (do not use error codes or 'failure' objects)
        - 1.2.2 Convert API data to models/dart primitive types or trigger changes in the database/hardware/local storage/...: nothing more, nothing less
        - 1.2.3 **ONLY PLACE TO CONNECT WITH external devices: HARDWARE/APIs/LOCAL STORAGE/...**
        - 1.2.4 **ONLY PLACE TO IMPORT PROVIDERS (eg: Firebase Firestore, Firebase Cloud Storage, ...)**
    - **1.3 models**
        - 1.3.1 ALWAYS EXTEND AN ENTITY from the `domain/entities` folder.
        - 1.3.2 Contain a `EntityClass toEntity()` function for conversion to entities
        - 1.3.3 Contain a `fromRawData` factory for conversion from external API data to model.
    - **1.4 repository**
        - 1.4.1 Name repository implementation classes as {Repository Interface Name}Impl
        - 1.4.2 Contains ONLY repository implementations of abstract classes in the `domain/repository`
        - 1.4.3 ALWAYS RETURN an ```DataState<Type>``` when requesting data from an API
        - 1.4.4 **ONLY PLACE TO IMPORT data_providers from**

2. **Business Layer Violations**
    - **2.1 General**
        - 2.1.1 NEVER IMPORT FROM ANY MODULE WITHIN THE PROJECT (except dart libraries)
    - **2.2 Entities**
        - 2.2.1 Do not implement any logic related to data fetching or presentation
        - 2.2.2 Implement any BUSINESS LOGIC related to business objects in here.
    - **2.3 use_cases**
        - 2.3.1 Each use case must implement a single business logic operation
        - 2.3.2 Do not directly interact with the data layer; use repository interfaces
    - **2.4 repository**
        - 2.4.1 Do not contain any implementation details, only abstract definitions (abstract classes)
        - 2.4.2 Never return models from `data/models`, return `domain/entities` instead.

3. **Presentation Layer Violations**
    - **3.1 General**
        - 3.1.1 Do not directly access the data layer or use data providers
        - 3.1.2 Avoid business logic in presentation components; use blocs/cubits for state management
    - **3.2 blocs**
        - 3.2.1 Blocs should only be used for UI state management and must not contain business logic
        - 3.2.2 ONLY PLACE to interact with use cases
        - 3.2.3 CAN ONLY INTERACT WITH USE_CASES for any business logic operation (not repositories or data_layer)
    - **3.3 screens**
        - 3.3.1 Ensure screens only handle presentation and delegate business logic to blocs or use cases
        - 3.3.2 Avoid direct dependency on specific models; use entities or simplified data structures
    - **3.4 widgets**
        - 3.4.1 Widgets should be reusable and not tied to specific business logic
        - 3.4.2 Should receive data through constructors or provided state management solutions