// Participation status constants matching backend database values
// These IDs correspond to seed data in Actime/SeedData.cs

/// Membership Status IDs
class MembershipStatus {
  MembershipStatus._();

  static const int pending = 1;
  static const int active = 2;
  static const int suspended = 3;
  static const int cancelled = 4;
  static const int expired = 5;
  static const int rejected = 6;

  static String getName(int id) {
    switch (id) {
      case pending:
        return 'Na čekanju';
      case active:
        return 'Aktivan';
      case suspended:
        return 'Suspendovan';
      case cancelled:
        return 'Otkazan';
      case expired:
        return 'Istekao';
      case rejected:
        return 'Odbijen';
      default:
        return 'Nepoznato';
    }
  }
}

/// Attendance Status IDs
class AttendanceStatus {
  AttendanceStatus._();

  static const int pendingResponse = 1;
  static const int going = 2;
  static const int maybe = 3;
  static const int notGoing = 4;
  static const int attended = 5;
  static const int missed = 6;

  static String getName(int id) {
    switch (id) {
      case pendingResponse:
        return 'Na čekanju';
      case going:
        return 'Ide';
      case maybe:
        return 'Možda';
      case notGoing:
        return 'Ne ide';
      case attended:
        return 'Prisustvovao';
      case missed:
        return 'Propustio';
      default:
        return 'Nepoznato';
    }
  }
}

/// Payment Status IDs
class PaymentStatus {
  PaymentStatus._();

  static const int pending = 1;
  static const int paid = 2;
  static const int failed = 3;
  static const int refunded = 4;

  static String getName(int id) {
    switch (id) {
      case pending:
        return 'Na čekanju';
      case paid:
        return 'Plaćeno';
      case failed:
        return 'Neuspjelo';
      case refunded:
        return 'Refundirano';
      default:
        return 'Nepoznato';
    }
  }
}

/// Payment Method IDs
class PaymentMethod {
  PaymentMethod._();

  static const int cash = 1;
  static const int bankTransfer = 2;
  static const int creditCard = 3;
  static const int payPal = 4;
  static const int invoice = 5;
  static const int other = 6;

  static String getName(int id) {
    switch (id) {
      case cash:
        return 'Gotovina';
      case creditCard:
        return 'Kreditna kartica';
      case bankTransfer:
        return 'Bankovni prijenos';
      case payPal:
        return 'PayPal';
      case invoice:
        return 'Faktura';
      case other:
        return 'Ostalo';
      default:
        return 'Nepoznato';
    }
  }
}
