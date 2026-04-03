import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppException handleException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    if (error is SocketException) {
      return AppException(
        message: 'Network error. Please check your internet connection.',
        code: 'network_error',
        originalError: error,
      );
    }

    return AppException(
      message: 'An unexpected error occurred. Please try again.',
      code: 'unknown_error',
      originalError: error,
    );
  }

  static AppException _handleAuthError(FirebaseAuthException error) {
    String message;

    switch (error.code) {
      case 'user-not-found':
        message = 'No account found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'This email is already registered.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many login attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      default:
        message = 'Authentication error: ${error.message}';
    }

    return AppException(
      message: message,
      code: error.code,
      originalError: error,
    );
  }

  static AppException _handleFirebaseError(FirebaseException error) {
    String message;

    switch (error.code) {
      case 'permission-denied':
        message = 'You do not have permission to perform this action.';
        break;
      case 'not-found':
        message = 'The requested data was not found.';
        break;
      case 'already-exists':
        message = 'This item already exists.';
        break;
      case 'failed-precondition':
        message = 'Operation failed. Please try again.';
        break;
      case 'aborted':
        message = 'Operation was aborted. Please try again.';
        break;
      case 'unavailable':
        message = 'Service is temporarily unavailable. Please try again later.';
        break;
      case 'deadline-exceeded':
        message = 'Request took too long. Please try again.';
        break;
      default:
        message = 'Database error: ${error.message}';
    }

    return AppException(
      message: message,
      code: error.code,
      originalError: error,
    );
  }

  static String getErrorMessage(dynamic error) {
    final appException = handleException(error);
    return appException.message;
  }
}

// Extension for easier error handling
extension ErrorHandling on Future {
  Future<T> handleError<T>() async {
    try {
      return await this as Future<T>;
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
