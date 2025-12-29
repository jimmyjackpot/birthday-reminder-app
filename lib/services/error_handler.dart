import 'package:flutter/foundation.dart';

enum ErrorType {
  network,
  storage,
  permission,
  validation,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final Object? originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'Connection issue. Please check your internet and try again.';
      case ErrorType.storage:
        return 'Unable to save data. Please try again or restart the app.';
      case ErrorType.permission:
        return 'Permission required. Please enable it in settings.';
      case ErrorType.validation:
        return message;
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  void log() {
    debugPrint('Error [${type.name}]: $message');
    if (originalError != null) {
      debugPrint('Original error: $originalError');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

class ErrorHandler {
  static AppError handleError(Object error, [StackTrace? stackTrace]) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return AppError(
        message: 'Network error occurred',
        type: ErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('permission') || 
        errorString.contains('denied')) {
      return AppError(
        message: 'Permission denied',
        type: ErrorType.permission,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('storage') || 
        errorString.contains('file') ||
        errorString.contains('save')) {
      return AppError(
        message: 'Storage error occurred',
        type: ErrorType.storage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('validation') || 
        errorString.contains('invalid')) {
      return AppError(
        message: error.toString(),
        type: ErrorType.validation,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppError(
      message: 'An unexpected error occurred',
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppError createValidationError(String message) {
    return AppError(
      message: message,
      type: ErrorType.validation,
    );
  }
}

