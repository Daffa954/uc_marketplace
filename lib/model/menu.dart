part of 'model.dart';

class MenuModel {
  final int? menuId;
  final int? restaurantId;
  final String name;
  final String? description;
  final String? image;
  final int price;
  final MenuType type;

  MenuModel({
    this.menuId,
    this.restaurantId,
    required this.name,
    this.description,
    this.image,
    required this.price,
    required this.type,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['menu_id'],
      restaurantId: json['restaurant_id'],
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      price: json['price'] ?? 0,
      type: enumFromString(MenuType.values, json['type']),
    );
  }

  Map<String, dynamic> toJson() => {
    'restaurant_id': restaurantId,
    'name': name,
    'description': description,
    'image': image,
    'price': price,
    'type': type.toString().split('.').last,
  };
}