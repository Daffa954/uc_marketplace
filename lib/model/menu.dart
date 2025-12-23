part of 'model.dart';

class MenuModel {
  final int? menuId;
  // Agar saat query join (PreOrder -> Menu), kita bisa simpan ID relasinya.
  final int? preOrderMenuId;
  final int? restaurantId;
  final String name;
  final String? description;
  final String? image;
  final int price;
  final MenuType type;
final int? generalCategoryId;
  MenuModel({
    this.menuId,
    this.preOrderMenuId,
    this.restaurantId,
    required this.name,
    this.description,
    this.image,
    required this.price,
    required this.type,
    this.generalCategoryId,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['menu_id'],
      restaurantId: json['restaurant_id'],
      preOrderMenuId: json['pre_order_menu_id'],
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      price: json['price'] ?? 0,
      type: enumFromString(MenuType.values, json['type']),
      generalCategoryId: json['general_category_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'restaurant_id': restaurantId,
    'name': name,
    'description': description,
    'image': image,
    'price': price,
    'type': type.toString().split('.').last,
    'general_category_id': generalCategoryId,
  };
}