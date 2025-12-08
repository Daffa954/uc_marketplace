part of 'model.dart';

class RestaurantModel {
  final int? id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? province;
  final int? ownerId;

  RestaurantModel({
    this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.province,
    this.ownerId,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['restaurants_id'],
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      ownerId: json['owners_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'address': address,
    'city': city,
    'province': province,
    'owners_id': ownerId,
  };
}