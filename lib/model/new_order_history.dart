
class NewOrderHistoryModel {
  final int orderId;
  final int total;
  final String status;
  final DateTime createdAt;
  final String restaurantName;
  final String restaurantLogo;
  final int itemCount;

  NewOrderHistoryModel({
    required this.orderId,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.itemCount,
  });

  factory NewOrderHistoryModel.fromSupabase(Map<String, dynamic> json) {
    final preOrder = json['pre_orders'] ?? {};
    final seller = preOrder['seller'] ?? {};
    final items = json['order_items'] as List? ?? [];

    return NewOrderHistoryModel(
      orderId: json['order_id'],
      total: json['total'] ?? 0,
      status: json['status'] ?? 'PENDING',
      createdAt: DateTime.parse(json['created_at']),
      restaurantName: seller['name'] ?? "Restaurant",
      restaurantLogo: seller['logo_url'] ?? "",
      itemCount: items.length,
    );
  }
}