import '../errors/failure.dart';

class ApiException implements Exception {
  const ApiException({
    required this.failure,
  });

  final Failure failure;

  @override
  String toString() {
    return failure.message;
  }
}