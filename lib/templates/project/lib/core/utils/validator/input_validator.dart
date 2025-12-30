class AppValidators {
  // ------------------------------------------
  // Email OR Phone Validator
  // ------------------------------------------
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field is required';
    }

    final input = value.trim();

    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');
    final phoneRegex = RegExp(r'^(\+?\d{1,3})?0?1[3-9]\d{8}$');

    if (!emailRegex.hasMatch(input) && !phoneRegex.hasMatch(input)) {
      return 'Enter a valid email or phone number';
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }

    final otp = value.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(otp)) {
      return 'Enter a valid 4-digit OTP';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field is required';
    }

    final input = value.trim();

    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');

    if (!emailRegex.hasMatch(input)) {
      return 'Enter a valid email';
    }

    return null;
  }

  // ------------------------------------------
  // Password Validator
  // ------------------------------------------
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    final pass = value.trim();

    if (pass.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final uppercase = RegExp(r'[A-Z]');
    final lowercase = RegExp(r'[a-z]');
    final number = RegExp(r'\d');
    final specialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    if (!uppercase.hasMatch(pass)) {
      return 'Include at least one uppercase letter';
    }
    if (!lowercase.hasMatch(pass)) {
      return 'Include at least one lowercase letter';
    }
    if (!number.hasMatch(pass)) {
      return 'Include at least one number';
    }
    if (!specialChar.hasMatch(pass)) {
      return 'Include at least one special character';
    }

    return null;
  }

  // ------------------------------------------
  // First Name Validator
  // ------------------------------------------
  static String? firstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'First name must be at least 2 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Invalid characters in first name';
    }

    return null;
  }

  // ------------------------------------------
  // Last Name Validator
  // ------------------------------------------
  static String? lastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }

    final name = value.trim();

    if (name.length < 2) {
      return 'Last name must be at least 2 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Invalid characters in last name';
    }

    return null;
  }

  // ------------------------------------------
  // Confirm Password Validator
  // ------------------------------------------
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (originalPassword == null || originalPassword.isEmpty) {
      return 'Enter password first';
    }

    if (value.trim() != originalPassword.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }
}
