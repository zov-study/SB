class PasswordFieldValidator {
  static String validate(String password) =>
      password.isEmpty ? 'Password can\'t be empty' : null;
}

class EmailFieldValidator {
  static String validate(String email) {
    if (email.isEmpty) return "Enter email address";

    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(email)) return null;

    return 'Email is not valid';
  }
}

class PhoneFieldValidator {
  static String validate(String phone) {
    if (phone.isEmpty) return "Enter phone number";
    String p = "[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3,6}";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(phone)) return null;

    return 'Phone number is not valid';
  }
}
