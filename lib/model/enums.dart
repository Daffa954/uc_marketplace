enum UserRole { USER, SELLER, ADMIN }

enum MenuType { FOOD, DRINK }

enum PaymentMethod { CASH, QRIS, TRANSFER }

enum PaymentStatus { PENDING, PAID, FAILED, REFUNDED }

// Helper untuk konversi String ke Enum (Safety)
T enumFromString<T>(List<T> values, String? value) {
  return values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => values.first, // Default value jika error/null
  );
}