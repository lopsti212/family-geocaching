class AuthErrorHandler {
  static String parse(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'E-Mail oder Passwort ist falsch';
    }
    if (message.contains('user already registered') ||
        message.contains('already been registered') ||
        message.contains('already registered') ||
        message.contains('duplicate')) {
      return 'Diese E-Mail ist bereits registriert';
    }
    if (message.contains('invalid email') ||
        message.contains('not a valid email')) {
      return 'Ungültige E-Mail-Adresse';
    }
    if (message.contains('weak password') ||
        message.contains('password should be')) {
      return 'Passwort ist zu schwach (mindestens 6 Zeichen)';
    }
    if (message.contains('network') ||
        message.contains('socketexception') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return 'Keine Internetverbindung';
    }
    if (message.contains('email rate limit') ||
        message.contains('rate limit')) {
      return 'Zu viele Versuche. Bitte warte einen Moment.';
    }

    return 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';
  }
}
