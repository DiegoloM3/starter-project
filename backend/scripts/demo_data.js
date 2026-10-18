// Demo content for the seed script: journalists publishing articles, readers who follow
// them and comment. Every id starts with "demo-" so the data can be found and removed.

export const DEMO_PASSWORD = 'Demo1234!';

export const JOURNALISTS = [
  {
    uid: 'demo-journalist-lucia',
    firstName: 'Lucía',
    lastName: 'Fernández',
    email: 'lucia.fernandez@example.com',
    bio: 'Periodista de tecnología y ciencia. Escribo sobre cómo la innovación cambia nuestra vida diaria.',
  },
  {
    uid: 'demo-journalist-martin',
    firstName: 'Martín',
    lastName: 'Rojas',
    email: 'martin.rojas@example.com',
    bio: 'Cronista deportivo desde hace quince años. Fútbol, atletismo y todo lo que se juega con el corazón.',
  },
  {
    uid: 'demo-journalist-valentina',
    firstName: 'Valentina',
    lastName: 'Cruz',
    email: 'valentina.cruz@example.com',
    bio: 'Cultura, cine y videojuegos. Creo que las buenas historias están en todas partes.',
  },
  {
    uid: 'demo-journalist-diego',
    firstName: 'Diego',
    lastName: 'Herrera',
    email: 'diego.herrera@example.com',
    bio: 'Economía y política internacional explicadas sin tecnicismos.',
  },
];

export const READERS = [
  { uid: 'demo-reader-camila', firstName: 'Camila', lastName: 'Soto', email: 'camila.soto@example.com', bio: '' },
  { uid: 'demo-reader-joaquin', firstName: 'Joaquín', lastName: 'Pérez', email: 'joaquin.perez@example.com', bio: 'Lector curioso.' },
  { uid: 'demo-reader-sofia', firstName: 'Sofía', lastName: 'Morales', email: 'sofia.morales@example.com', bio: '' },
];

// [followerId, followedId]
export const FOLLOWS = [
  ['demo-reader-camila', 'demo-journalist-lucia'],
  ['demo-reader-camila', 'demo-journalist-valentina'],
  ['demo-reader-joaquin', 'demo-journalist-martin'],
  ['demo-reader-joaquin', 'demo-journalist-diego'],
  ['demo-reader-joaquin', 'demo-journalist-lucia'],
  ['demo-reader-sofia', 'demo-journalist-valentina'],
  ['demo-journalist-lucia', 'demo-journalist-diego'],
  ['demo-journalist-diego', 'demo-journalist-lucia'],
  ['demo-journalist-valentina', 'demo-reader-camila'],
];

// Blocks of the rich content: { p }, { h }, { list: [...] } and { quote }. Paragraphs accept
// segments such as { bold: 'text' } or { highlight: 'text' } to show the editor formats.
export const ARTICLES = [
  {
    id: 'demo-article-1',
    authorId: 'demo-journalist-lucia',
    daysAgo: 0.2,
    topics: ['technology', 'culture'],
    title: 'La inteligencia artificial llega a las redacciones',
    description: 'Periodistas de cinco medios cuentan cómo usan las nuevas herramientas sin perder su criterio.',
    content: [
      { p: ['Hace apenas dos años parecía ciencia ficción. Hoy, muchas redacciones usan la inteligencia artificial para ', { bold: 'transcribir entrevistas' }, ', resumir documentos y revisar datos.'] },
      { h: 'Lo que sí hace bien' },
      { list: ['Transcribir horas de audio en minutos.', 'Encontrar patrones en grandes bases de datos.', 'Sugerir titulares alternativos.'] },
      { h: 'Lo que no puede reemplazar' },
      { p: ['Todos los entrevistados coinciden: ', { highlight: 'la verificación y el criterio siguen siendo humanos' }, '. Una herramienta puede equivocarse con total seguridad.'] },
      { quote: 'La tecnología nos da tiempo. Lo importante es en qué lo usamos.' },
    ],
  },
  {
    id: 'demo-article-2',
    authorId: 'demo-journalist-martin',
    daysAgo: 0.6,
    topics: ['sports'],
    title: 'La remontada que nadie esperaba en la final',
    description: 'Con dos goles en contra al descanso, el equipo visitante escribió una de las mejores historias de la temporada.',
    content: [
      { p: ['Nadie en el estadio apostaba por ellos. Al descanso perdían ', { bold: '2 a 0' }, ' y su delantero estrella se había retirado lesionado.'] },
      { h: 'Un segundo tiempo para la historia' },
      { p: ['El entrenador cambió el sistema y adelantó la presión. En veinte minutos llegaron el empate y, en el último suspiro, ', { highlight: 'el gol de la victoria' }, '.'] },
      { quote: 'En el vestuario nos dijimos que todavía quedaban 45 minutos. Solo eso.' },
    ],
  },
  {
    id: 'demo-article-3',
    authorId: 'demo-journalist-valentina',
    daysAgo: 1.1,
    topics: ['gaming', 'culture'],
    title: 'Los videojuegos independientes que marcaron el año',
    description: 'Estudios pequeños demostraron que una gran idea importa más que un presupuesto millonario.',
    content: [
      { p: ['Este año, varios de los juegos más comentados no vinieron de grandes compañías, sino de ', { bold: 'equipos de menos de diez personas' }, '.'] },
      { h: 'Tres títulos imprescindibles' },
      { list: ['Un juego de exploración que se cuenta sin una sola palabra.', 'Un simulador de jardinería sorprendentemente emotivo.', 'Un plataformas que reinventa la gravedad en cada nivel.'] },
      { p: ['Lo que tienen en común es ', { highlight: 'una idea clara y la valentía de llevarla hasta el final' }, '.'] },
    ],
  },
  {
    id: 'demo-article-4',
    authorId: 'demo-journalist-diego',
    daysAgo: 1.7,
    topics: ['economy'],
    title: 'Cómo afecta la inflación al precio del café',
    description: 'Del cafetal a la taza: por qué el café de la mañana cuesta hoy un 30% más que hace dos años.',
    content: [
      { p: ['El precio del café en el supermercado depende de mucho más que la cosecha. Influyen el ', { bold: 'transporte' }, ', el tipo de cambio y el clima.'] },
      { h: 'Los tres factores clave' },
      { list: ['Sequías en los principales países productores.', 'El aumento del costo de los fletes marítimos.', 'La depreciación de las monedas locales.'] },
      { p: ['Los expertos esperan que ', { highlight: 'los precios se estabilicen el próximo año' }, ', aunque no volverán a los niveles anteriores.'] },
    ],
  },
  {
    id: 'demo-article-5',
    authorId: 'demo-journalist-lucia',
    daysAgo: 2.4,
    topics: ['science'],
    title: 'El telescopio que fotografió el nacimiento de una estrella',
    description: 'Las nuevas imágenes muestran con un detalle inédito cómo se forma una estrella a partir de gas y polvo.',
    content: [
      { p: ['A más de mil años luz de la Tierra, una nube de gas se está convirtiendo en una estrella. Y por primera vez la podemos ', { bold: 'ver con claridad' }, '.'] },
      { h: 'Por qué es importante' },
      { p: ['Estas imágenes ayudan a entender cómo se formó nuestro propio Sol hace unos ', { highlight: '4.600 millones de años' }, '.'] },
    ],
  },
  {
    id: 'demo-article-6',
    authorId: 'demo-journalist-martin',
    daysAgo: 3.2,
    topics: ['sports', 'health', 'science'],
    title: 'Correr maratones después de los 50: lo que dice la ciencia',
    description: 'Cada vez más personas debutan en la distancia más exigente después de los cincuenta años.',
    content: [
      { p: ['La edad promedio de quienes corren su primer maratón no deja de subir. Los médicos consultados coinciden en que ', { bold: 'no hay una edad límite' }, ', pero sí reglas básicas.'] },
      { h: 'Consejos para empezar' },
      { list: ['Hacerse un chequeo médico antes de entrenar.', 'Aumentar la distancia de forma gradual.', 'Dar al descanso la misma importancia que al entrenamiento.'] },
    ],
  },
  {
    id: 'demo-article-7',
    authorId: 'demo-journalist-valentina',
    daysAgo: 4.0,
    topics: ['entertainment', 'culture'],
    title: 'El regreso del cine de autor a las salas',
    description: 'Después de años dominados por las franquicias, el público vuelve a llenar las salas para ver historias originales.',
    content: [
      { p: ['Las cifras de taquilla sorprenden: tres de las diez películas más vistas del trimestre son ', { bold: 'historias originales' }, ' de directores con estilo propio.'] },
      { quote: 'El público nunca dejó de querer historias nuevas. Solo necesitaba que se las ofrecieran.' },
    ],
  },
  {
    id: 'demo-article-8',
    authorId: 'demo-journalist-diego',
    daysAgo: 5.1,
    topics: ['politics', 'world', 'science'],
    title: 'Lo que está en juego en la cumbre climática',
    description: 'Casi doscientos países negocian cómo financiar la transición energética de las economías emergentes.',
    content: [
      { p: ['La cumbre de este año gira en torno a una pregunta: ', { highlight: '¿quién paga la transición?' }, ' Los países en desarrollo piden más financiamiento.'] },
      { h: 'Los puntos de la negociación' },
      { list: ['Un fondo para pérdidas y daños.', 'Metas de reducción de emisiones más ambiciosas.', 'El calendario para dejar el carbón.'] },
    ],
  },
  {
    id: 'demo-article-9',
    authorId: 'demo-journalist-lucia',
    daysAgo: 6.3,
    topics: ['technology', 'health'],
    title: 'Relojes inteligentes que detectan enfermedades antes que el médico',
    description: 'Los sensores de muñeca ya alertan de arritmias, y los investigadores trabajan en detectar mucho más.',
    content: [
      { p: ['Un reloj inteligente mide el ritmo cardíaco cientos de veces al día. Con esos datos, algunos modelos ya pueden ', { bold: 'avisar de una arritmia' }, '.'] },
      { p: ['Los especialistas advierten que ', { highlight: 'no reemplazan una consulta médica' }, ', pero sí pueden ser una primera señal de alerta.'] },
    ],
  },
  {
    id: 'demo-article-10',
    authorId: 'demo-journalist-diego',
    daysAgo: 7.5,
    topics: ['economy', 'technology'],
    title: 'Las startups latinoamericanas que atraen inversión',
    description: 'Pagos digitales, logística y salud lideran las rondas de inversión en la región.',
    content: [
      { p: ['La región vive un momento de crecimiento para las empresas tecnológicas. Los sectores con más inversión son ', { bold: 'pagos digitales, logística y salud' }, '.'] },
      { h: 'Por qué ahora' },
      { list: ['Más personas con acceso a internet móvil.', 'Fondos de inversión locales cada vez más grandes.', 'Talento técnico con experiencia internacional.'] },
    ],
  },
];

export const COMMENTS = [
  { articleId: 'demo-article-1', authorId: 'demo-reader-camila', hoursAfter: 1, text: 'Muy interesante. Me gustó que se hable también de los límites de la herramienta.' },
  { articleId: 'demo-article-1', authorId: 'demo-reader-joaquin', hoursAfter: 2, text: '¿Alguien sabe qué herramienta usan para transcribir?' },
  { articleId: 'demo-article-1', authorId: 'demo-journalist-diego', hoursAfter: 3, text: 'Gran artículo, Lucía. La parte de la verificación es clave.' },
  { articleId: 'demo-article-2', authorId: 'demo-reader-joaquin', hoursAfter: 1, text: '¡Qué partido! Lo vi en vivo y todavía no me lo creo.' },
  { articleId: 'demo-article-2', authorId: 'demo-reader-sofia', hoursAfter: 4, text: 'El cambio de sistema en el segundo tiempo fue lo que lo definió.' },
  { articleId: 'demo-article-3', authorId: 'demo-reader-camila', hoursAfter: 2, text: 'El de jardinería me hizo llorar, lo recomiendo muchísimo.' },
  { articleId: 'demo-article-3', authorId: 'demo-reader-sofia', hoursAfter: 5, text: 'Faltó mencionar alguno de terror, pero la lista está muy buena.' },
  { articleId: 'demo-article-4', authorId: 'demo-reader-joaquin', hoursAfter: 3, text: 'Por fin alguien lo explica de forma clara.' },
  { articleId: 'demo-article-5', authorId: 'demo-reader-camila', hoursAfter: 6, text: 'Las imágenes deben ser impresionantes. ¿Dónde se pueden ver?' },
  { articleId: 'demo-article-6', authorId: 'demo-reader-sofia', hoursAfter: 2, text: 'Mi papá corrió su primer maratón a los 55. ¡Totalmente posible!' },
  { articleId: 'demo-article-7', authorId: 'demo-reader-camila', hoursAfter: 8, text: 'Ojalá esta tendencia continúe.' },
  { articleId: 'demo-article-8', authorId: 'demo-reader-joaquin', hoursAfter: 5, text: 'La pregunta de quién paga es la de siempre.' },
  { articleId: 'demo-article-10', authorId: 'demo-reader-sofia', hoursAfter: 4, text: 'Trabajo en una startup de logística y se nota mucho el interés.' },
];
