class ServiceException implements Exception {
  final String code;
  final String message;

  const ServiceException({
    this.code,
    this.message,
  });
}
