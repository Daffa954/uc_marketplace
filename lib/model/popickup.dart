part of 'model.dart';

class PoPickupModel {
  final int preOrderId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? address;
  final double? longitude;
  final double? altitude;
  final Map<String, dynamic>? photoLocation; // JSONB di Postgres

  PoPickupModel({
    required this.preOrderId,
    this.date,
    this.startTime,
    this.endTime,
    this.address,
    this.longitude,
    this.altitude,
    this.photoLocation,
  });

  factory PoPickupModel.fromJson(Map<String, dynamic> json) {
    return PoPickupModel(
      preOrderId: json['pre_order_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      address: json['address'],
      // Konversi aman ke double
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      photoLocation: json['photo_location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'pre_order_id': preOrderId,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'address': address,
    'longitude': longitude,
    'altitude': altitude,
    'photo_location': photoLocation,
  };
}