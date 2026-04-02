import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ErrorHandler {
  /// Parse Firebase exceptions and return user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else if (error is SocketException) {
      return 'Network error. Please check your connection.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else {
      return error.toString().contains('Failed')
          ? error.toString()
          : 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle Firebase Authentication errors
  static String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication error: ${error.message}';
    }
  }

  /// Handle Firestore errors
  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This item already exists.';
      case 'failed-precondition':
        return 'Operation failed. Please try again.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'The value is out of range.';
      case 'unimplemented':
        return 'This feature is not yet implemented.';
      case 'internal':
        return 'Internal server error. Please try again later.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again later.';
      case 'data-loss':
        return 'Data loss occurred. Please try again.';
      case 'unauthenticated':
        return 'Please log in to continue.';
      default:
        return 'Error: ${error.message}';
    }
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is TimeoutException ||
        (error is FirebaseException && error.code == 'unavailable');
  }

  /// Check if error is authentication-related
  static bool isAuthError(dynamic error) {
    return error is FirebaseAuthException ||
        (error is FirebaseException && error.code == 'unauthenticated');
  }

  /// Check if error is permission-related
  static bool isPermissionError(dynamic error) {
    return error is FirebaseException && error.code == 'permission-denied';
  }
}

// Import these for error handling
class SocketException implements Exception {
  final String message;
  SocketException(this.message);
  
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
