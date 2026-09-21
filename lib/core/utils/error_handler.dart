class ErrorHandler {
  static String message(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission-denied') || text.contains('permission_denied')) {
      return 'You do not have permission to do that.';
    }
    if (text.contains('network') || text.contains('unavailable')) {
      return 'Network issue. Please check your connection and try again.';
    }
    if (text.contains('user-not-found') || text.contains('wrong-password') ||
        text.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (text.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (text.contains('weak-password')) {
      return 'Please choose a stronger password.';
    }
    if (text.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment.';
    }
    if (text.contains('cloudinary')) {
      return 'Image upload failed. Please try another image.';
    }
    return 'Something went wrong. Please try again.';
  }
}
