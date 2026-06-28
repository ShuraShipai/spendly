import 'auth_constants.dart';

class AuthValidators {
  const AuthValidators._();

  static final _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static String? displayName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AuthConstants.nameRequired;
    }
    if (trimmed.length > AuthConstants.maxDisplayNameLength) {
      return AuthConstants.nameTooLong;
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AuthConstants.emailRequired;
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      return AuthConstants.emailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return AuthConstants.passwordRequired;
    }
    if (password.length < AuthConstants.minPasswordLength) {
      return AuthConstants.passwordTooShort;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return AuthConstants.confirmPasswordRequired;
    }
    if (confirmation != password) {
      return AuthConstants.passwordsDoNotMatch;
    }
    return null;
  }
}
