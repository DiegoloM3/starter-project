### Introducción

Cuando leí el proyecto pensé que era solo una app Flutter,
después me di cuenta que también estaba a cargo de implementar 
el backend con Firebase, lo cual me pareció un reto interesante,
pues he usado la plataforma antes pero no había implementado un
proyecto completo con ella y la única vez que usé Firestore y Storage
fue hace ya varios años, por lo que veo que ya han cambiado muchas cosas.

### Proceso de aprendizaje
Para aprender a usar Firebase, seguí la documentación oficial recomendada
por el readme(https://firebase.google.com/docs/firestore/security/rules-structure),
aunque siendo honesto, tuve que recurrir a Claude para refinar las reglas
de seguridad; para Firestore ya tenía algo de experiencia y pude 
implementar la estructura de la base de datos sin problemas 
(aunque no soy muy fan de NoSQL).
Sobre BLoC ya tenía algo de experiencia y solo fue refinar algunos detalles
con búsquedas en Google y StackOverflow.

### Retos encontrados
Como ya lo mencioné, el reto más grande fue aprender a implementar las reglas
de seguridad de Firestore, aunque con la ayuda de Claude y la documentación 
siento que cumplen con lo esperado, aunque me gustaría recibir feedback sobre
ellas para mejorarlas.
Otro reto que me consumió algo de tiempo fue reparar las dependencias de Flutter,
tuve que actualizar algunas y eliminar otras para que el proyecto se compilara sin problemas.
Personalmente para mi las apps con diseño bastante simple me causan problemas,
por lo que me apoyé de Pencil para obtener un diseño más moderno y agregué algunas
funcionalidades extra para hacer la UX un poco mejor, por lo que el usuario se 
sienta más cómodo usando la app.
Entender la diferencia entre Blocs y Cubits también fue un pequeño reto, aunque 
al final creo que logré usarlos de la manera correcta y saber cuándo usar cuál.

### Reflexión y planes para el futuro
Pese a ser un proyecto pequeño, siento que aprendí bastante sobre Firebase y su integración
pero además noté que está pensado para que un desarrollador se extienda y agregue
cuanta funcionalidad quiera, lo cual me parece genial, ya que deja entrever la 
experiencia de uno como desarrollador y cómo manejar escalabilidad.
A futuro, entre otras cosas, considero que debería agregar lo siguiente:
- Agregar un sistema de autenticación para que los usuarios guarden su info, pero tengan
  tracking de lo que publican de manera segura. Actualmente no podría asegurar que otro 
  usuario no borre o edite lo que alguien más publicó, lo cual es un gran problema.
- A nivel técnico, quizá migrar a Supabase, que es una herramienta similar a Firebase
  pero con una base de datos SQL, lo cual me parece más cómodo de manejar y escalar.
- Integrar Freezed para evitar tener que escribir código repetitivo para los modelos, creo que 
  es una buena práctica y me ahorraría algo de tiempo (pese a que son tareas fáciles para AI).
- Mejorar el coverage de los unit tests, así como integrar Golden Tests (En Flutter es muy
  común que haya render issues por la gran cantidad de dispositivos y tamaños de pantalla).
- Lanzar la búsqueda hacia las apis y no solo en local.
- Pese a que existe UI, no logré implementar la funcionalidad de compartir, que se me hace un plus.

### Evidencias
- Repositorio: https://github.com/jmorasot/starter-project
- Capturas de pantalla:
   - Home - Firestore Tab => https://drive.google.com/file/d/1nSeiPqgWI1xQ4Krutk8wC_8nF4zk2OEY/view?usp=sharing, 
   - Home - NewsApi Tab => https://drive.google.com/file/d/1cJDozWfFmMGjqKzz37L5wbzopkKSEF1j/view?usp=sharing, 
   - Home - Filter => https://drive.google.com/file/d/1zjNVu9A78VwuSYBc6_MklOrnU7rJA_45/view?usp=sharing,
   - News Detail => https://drive.google.com/file/d/1F2Z_W3Z_R3v-nl8OvqZC9ZEW8KlIiJ2o/view?usp=sharing, 
   - Profile Screen => https://drive.google.com/file/d/1gp8LzODs_z12fCOLYdqz_11lP5Iy2N12/view?usp=sharing, 
   - New Article => https://drive.google.com/file/d/1Hye1TLYxycgoDNvSMxEoXiRqGkm6SN7t/view?usp=sharing, 
   - New Article - Add Photo => https://drive.google.com/file/d/10kW1qnwPUrLNb8tKl6Zay8ZqqjS_DFQc/view?usp=sharing

### Adicionales
- Perfil: Creado para mostrar la información del usuario, aunque actualmente no hay un sistema 
  de autenticación, por lo que no hay datos de Servidor. También muestra los artículos que no se han
  publicado aún, lo cual es una funcionalidad extra que agregué para mejorar la UX, así como los guardados.
- Búsqueda: Agregué un sistema de búsqueda para que el usuario pueda buscar noticias, aunque 
  actualmente solo funciona con los artículos que se muestran en la pantalla.
- Filtros con chips: Cuando un usuario crea un artículo, puede agregarle tags para que se clasifique mejor, aunque también es posible
  y así poder filtrar las noticias; en los artículos de NewsApi no se muestran dado que es más complejo.
- Explorar contenido completo: Se agregó un botón para poder leer el artículo completo desde la web
  del autor, dado que news api no ofrece el texto completo.

#### Prototipos
Se creó un diseño en Pencil para tener una mejor idea de cómo se vería la app, aunque el diseño final 
cambió un poco, me ayudó a tener una mejor idea de cómo organizar los elementos y decidir
qué agregar al proyecto.
Enlace: https://drive.google.com/file/d/1FfPOxrH-gkAIFaIDZN_q38xEpPrVLgQ-/view?usp=sharing