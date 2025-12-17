part of 'model.dart';

class PoPickupModel {
  final int? poPickupId;
  final int preOrderId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? address; // Maps to 'address' (Place Name)
  final String? detailAddress; // New: Maps to 'detail_address' (Description)
  final double? longitude;
  final double? latitude; // We keep 'latitude' in Dart for clarity

  // photo_location(json) in schema
  final List<String>? photoLocation; 

  PoPickupModel({
    this.poPickupId,
    required this.preOrderId,
    this.date,
    this.startTime,
    this.endTime,
    this.address,
    this.detailAddress,
    this.longitude,
    this.latitude,
    this.photoLocation,
  });

  factory PoPickupModel.fromJson(Map<String, dynamic> json) {
    return PoPickupModel(
      preOrderId: json['pre_order_id'] ?? 0,
      poPickupId: json['po_pickup_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      address: json['address'],
      detailAddress: json['detail_address'], // Map from schema
      longitude: (json['longitude'] as num?)?.toDouble(),
      // Maps schema 'altitude' key to our 'latitude' property
      latitude: (json['altitude'] as num?)?.toDouble(), 
      photoLocation: json['photo_location'] != null
          ? List<String>.from(json['photo_location'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'pre_order_id': preOrderId,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'address': address,
    'detail_address': detailAddress, // Match schema
    'longitude': longitude,
    // IMPORTANT: Map Dart 'latitude' back to schema key 'altitude'
    'altitude': latitude, 
    'photo_location': photoLocation,
  };
}