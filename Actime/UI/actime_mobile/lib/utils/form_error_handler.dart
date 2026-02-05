class FormErrorHandler {
  static final Map<String, String> _fieldNameMap = {
    // Auth fields
    'Email': 'email',
    'Password': 'password',
    'ConfirmPassword': 'confirmPassword',
    'CurrentPassword': 'currentPassword',
    'NewPassword': 'newPassword',
    'Username': 'username',

    // User fields
    'FirstName': 'firstName',
    'LastName': 'lastName',
    'DateOfBirth': 'dateOfBirth',
    'ProfileImageUrl': 'profileImageUrl',

    // Organization fields
    'Name': 'name',
    'PhoneNumber': 'phone',
    'Description': 'description',
    'LogoUrl': 'logoUrl',
    'CategoryId': 'categoryId',
    'AddressId': 'addressId',

    // Event fields
    'Title': 'title',
    'Start': 'start',
    'End': 'end',
    'LocationId': 'locationId',
    'MaxParticipants': 'maxParticipants',
    'Price': 'price',
    'IsFree': 'isFree',
    'ActivityTypeId': 'activityTypeId',
    'OrganizationId': 'organizationId',

    // Address fields
    'Street': 'street',
    'CityId': 'cityId',
    'PostalCode': 'postalCode',
    'Coordinates': 'coordinates',

    // Location fields
    'Capacity': 'capacity',
    'ContactInfo': 'contactInfo',
  };

  /// Backend returns: { "FieldName": ["Error 1", "Error 2"] }
  static Map<String, String> mapApiErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return {};

    final result = <String, String>{};

    errors.forEach((key, value) {
      final fieldName = _fieldNameMap[key] ?? _toCamelCase(key);

      if (value is List && value.isNotEmpty) {
        result[fieldName] = value.first.toString();
      } else if (value is String) {
        result[fieldName] = value;
      }
    });

    return result;
  }

  static String? getFieldError(
      String fieldName, Map<String, String> fieldErrors) {
    return fieldErrors[fieldName];
  }

  static Map<String, String> clearErrors() {
    return {};
  }

  static String _toCamelCase(String pascalCase) {
    if (pascalCase.isEmpty) return pascalCase;
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  static bool hasErrors(Map<String, String> fieldErrors) {
    return fieldErrors.isNotEmpty;
  }

  static void addFieldMapping(String backendName, String frontendName) {
    _fieldNameMap[backendName] = frontendName;
  }

  static String? combineErrors(String? frontendError, String? apiError) {
    return apiError ?? frontendError;
  }
}
