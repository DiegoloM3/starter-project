class AppError {
  final String message;
  final int? statusCode;

  const AppError({required this.message, this.statusCode});
}
