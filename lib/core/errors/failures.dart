import 'package:equatable/equatable.dart';
import 'exceptions.dart';

/// Failure base class for Bloc
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? code;
  const ServerFailure(String message, [this.code]) : super(message);

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(exception.message, exception.code);
  }
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(exception.message);
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);

  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(exception.message);
  }
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);

  factory AuthFailure.fromException(AuthException exception) {
    return AuthFailure(exception.message);
  }
}
