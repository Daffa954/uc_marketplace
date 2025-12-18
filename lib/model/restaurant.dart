part of 'model.dart';

class RestaurantModel {
  final int? id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? province;
  final String? ownerId;
  final String? bankAccount;

  RestaurantModel({
    this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.province,
    this.ownerId,
    this.bankAccount,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['restaurants_id'],
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      ownerId: json['owner_id'],
      bankAccount: json['bank_account'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'address': address,
    'city': city,
    'province': province,
    'owner_id': ownerId,
    'bank_account': bankAccount,
  };
}