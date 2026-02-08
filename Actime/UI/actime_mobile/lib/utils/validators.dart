/// Centralizirani validatori za forme
class Validators {
  // Regex patterni
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9\s\-]{8,15}$',
  );

  static final RegExp _usernameRegex = RegExp(
    r'^[a-zA-Z0-9_.]+$',
  );

  /// Validira da polje nije prazno
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezno';
    }
    return null;
  }

  /// Validira email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Let required handle empty
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Unesite validnu email adresu (npr. korisnik@primjer.com)';
    }
    return null;
  }

  /// Validira username format (samo slova, brojevi, donja crta i tačka)
  static String? username(String? value) {
    if (value == null || value.isEmpty) return null; // Let required handle empty
    if (value.length < 3) {
      return 'Korisničko ime mora imati najmanje 3 znaka';
    }
    if (value.length > 50) {
      return 'Korisničko ime može imati maksimalno 50 znakova';
    }
    if (!_usernameRegex.hasMatch(value.trim())) {
      return 'Korisničko ime može sadržavati samo slova, brojeve, tačku i donju crtu';
    }
    return null;
  }

  /// Validira format broja telefona
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Unesite validan broj telefona (8-15 cifara)';
    }
    return null;
  }

  /// Validira minimalnu dužinu
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) return null; // Let required handle empty
    if (value.length < min) {
      return '$fieldName mora imati najmanje $min znakova';
    }
    return null;
  }

  /// Validira maksimalnu dužinu
  static String? maxLength(String? value, int max, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '$fieldName može imati maksimalno $max znakova';
    }
    return null;
  }

  /// Validira da se dva polja podudaraju (npr. lozinka i potvrda)
  static String? match(String? value, String other, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (value != other) {
      return '$fieldName se ne podudara';
    }
    return null;
  }

  /// Validira da je vrijednost numerička
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName mora biti broj';
    }
    return null;
  }

  /// Validira da je vrijednost pozitivan broj
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName mora biti pozitivan broj';
    }
    return null;
  }

  /// Validira minimalnu vrijednost
  static String? minValue(String? value, double min, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < min) {
      return '$fieldName mora biti najmanje $min';
    }
    return null;
  }

  /// Komponira više validatora u jedan
  /// Vraća prvi error ili null ako su svi validni
  static String? Function(String?) compose(
      List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Helper za kreiranje required validatora s custom field imenom
  static String? Function(String?) requiredField(String fieldName) {
    return (value) => required(value, fieldName);
  }

  /// Helper za kreiranje minLength validatora
  static String? Function(String?) minLengthField(int min, String fieldName) {
    return (value) => minLength(value, min, fieldName);
  }

  /// Helper za kreiranje maxLength validatora
  static String? Function(String?) maxLengthField(int max, String fieldName) {
    return (value) => maxLength(value, max, fieldName);
  }

  /// Validira dropdown selekciju (ne smije biti null ili prazan string)
  static String? requiredSelection(dynamic value, String fieldName) {
    if (value == null || (value is String && value.isEmpty)) {
      return 'Odaberite $fieldName';
    }
    return null;
  }

  /// Validira da je datum u budućnosti
  static String? futureDate(DateTime? value, String fieldName) {
    if (value == null) return null;
    if (value.isBefore(DateTime.now())) {
      return '$fieldName mora biti u budućnosti';
    }
    return null;
  }

  /// Validira URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Unesite validan URL';
    }
    return null;
  }

  /// Validira IBAN format (za bankarske račune)
  static String? iban(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    final ibanRegex = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$');
    if (!ibanRegex.hasMatch(cleaned) || cleaned.length < 15 || cleaned.length > 34) {
      return 'Unesite validan IBAN (npr. BA391234567890123456)';
    }
    return null;
  }

  /// Validira PDV/PIB broj
  static String? taxId(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 12 || value.length > 13) {
      return 'Unesite validan broj (12-13 cifara)';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIB može sadržavati samo brojeve';
    }
    return null;
  }

  /// Validira pozitivan cijeli broj
  static String? positiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName mora biti pozitivan cijeli broj';
    }
    return null;
  }
}
