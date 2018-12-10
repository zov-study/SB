class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class EmailFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Enter email address";
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }
}

class PhoneFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Enter phone number";
    }
    // This is just a regular expression for email addresses
    String p = "[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3,6}";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the phone number is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return 'Phone number is not valid';
  }
}
