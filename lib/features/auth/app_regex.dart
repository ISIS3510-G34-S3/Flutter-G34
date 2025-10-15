class AppRegex {
  const AppRegex._();

  static final RegExp emailRegex = RegExp(
      r'^(?!.*\.{2})[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)*@[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)*\.[A-Za-z]{2,}$');
  static final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$#!%?&_])[A-Za-z\d@$#!%?&_]{8,}$');

  // Individual password requirement checks
  static final RegExp passwordHasLowercase = RegExp(r'[a-z]');
  static final RegExp passwordHasUppercase = RegExp(r'[A-Z]');
  static final RegExp passwordHasDigit = RegExp(r'\d');
  static final RegExp passwordHasSpecialChar = RegExp(r'[@$#!%?&_]');

  static final RegExp passwordHasSpace = RegExp(r'\s');
  static final RegExp passwordHasEmoji = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true);
  static final RegExp passwordHasInvalidChar = RegExp(r'[^A-Za-z\d@$#!%?&_]');
  static final RegExp nameRegex = RegExp(r"^[a-zA-Z]+( [a-zA-Z]+)?$");
  static final RegExp phoneRegex = RegExp(r"^[0-9]{10}$");
}
