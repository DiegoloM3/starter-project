/// Texts of the legal pages. This app is a technical test, so they describe how the app
/// works instead of being a real legal agreement.
enum LegalDocument {
  termsAndConditions(
    title: 'Términos y condiciones',
    sections: [
      (
        heading: 'Sobre esta aplicación',
        body:
            'Symmetry News es una aplicación de demostración creada como prueba técnica. '
            'No es un servicio comercial y su contenido puede borrarse en cualquier momento.',
      ),
      (
        heading: 'Cuentas y roles',
        body:
            'Toda cuenta nueva es de lector: puede leer, guardar y comentar artículos, y seguir a otros usuarios. '
            'Solo un administrador puede asignar el rol de periodista, que permite publicar.',
      ),
      (
        heading: 'Contenido publicado',
        body:
            'Cada periodista es responsable de los artículos que publica, y cada usuario de sus comentarios. '
            'No se permite publicar contenido ilegal, ofensivo o que suplante a otra persona.',
      ),
      (
        heading: 'Eliminación de la cuenta',
        body:
            'Puedes eliminar tu cuenta desde Configuración. Se borran tu perfil, tus guardados, tu historial '
            'y los usuarios que sigues. Los artículos y comentarios publicados se conservan con tu nombre.',
      ),
    ],
  ),
  legalNotice(
    title: 'Aviso legal',
    sections: [
      (
        heading: 'Responsable',
        body: 'Aplicación desarrollada como prueba técnica para el puesto de Junior Mobile Engineer en Symmetry.',
      ),
      (
        heading: 'Datos que se guardan',
        body:
            'Nombre, apellido, biografía, foto de perfil y email. El email es privado y solo lo puede leer su dueño. '
            'También se guardan los artículos guardados, el historial de lectura y la preferencia de notificaciones.',
      ),
      (
        heading: 'Dónde se guardan',
        body:
            'Los datos se almacenan en Firebase (Google Cloud). Las reglas de seguridad impiden que un usuario '
            'lea los datos privados de otro o publique en su nombre.',
      ),
      (
        heading: 'Imágenes',
        body: 'Las imágenes de los artículos de demostración provienen de Lorem Picsum (picsum.photos).',
      ),
    ],
  );

  final String title;
  final List<({String heading, String body})> sections;

  const LegalDocument({required this.title, required this.sections});
}
