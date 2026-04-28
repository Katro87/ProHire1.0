import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getHumanReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please login instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 8 characters with uppercase and numbers.';
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again later.';
      }
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('email-already-in-use') || errorString.contains('useralreadyexist')) {
      return 'This email is already registered. Please login instead.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Use at least 8 characters with uppercase and numbers.';
    }
    if (errorString.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please wait and try again later.';
    }
    if (errorString.contains('permission-denied')) {
      return 'Access denied. You don\'t have permission to do this.';
    }
    if (errorString.contains('not-found')) {
      return 'Document not found.';
    }

    return 'Something went wrong. Please try again.';
  }

  static String getSuccessMessage(String action) {
    switch (action) {
      case 'signup':
        return '✅ Account created successfully!';
      case 'login':
        return '✅ Welcome back!';
      case 'profileUpdate':
        return '✅ Profile updated successfully!';
      case 'photoUpload':
        return '✅ Photo uploaded successfully!';
      case 'jobRequest':
        return '✅ Request sent to professional!';
      case 'jobAccepted':
        return '✅ Job accepted! Let\'s get to work!';
      case 'jobDeclined':
        return '❌ Job declined';
      case 'payment':
        return '✅ Payment successful!';
      case 'logout':
        return '👋 Logged out successfully!';
      default:
        return '✅ Success!';
    }
  }
}