part of 'model.dart';

class PoPickupModel {
  final int? poPickupId; // Tambahkan ID unik tabel ini jika ada (opsional tapi disarankan)
  final int preOrderId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? address;
  final double? longitude;
  final double? latitude;
  final List<String>? photoLocation;

  PoPickupModel({
    this.poPickupId,
    required this.preOrderId,
    this.date,
    this.startTime,
    this.endTime,
    this.address,
    this.longitude,
    this.latitude,
    this.photoLocation,
  });

  factory PoPickupModel.fromJson(Map<String, dynamic> json) {
    return PoPickupModel(
      preOrderId: json['pre_order_id'],
      poPickupId: json['po_pickup_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      address: json['address'],
      // Konversi aman ke double
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['altitude'] as num?)?.toDouble(),
      photoLocation: json['photo_location'] != null
          ? List<String>.from(json['photo_location'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'pre_order_id': preOrderId,
    'po_pickup_id': poPickupId,
    'date': date,
    'start_time': startTime,
    'end_time': endTime,
    'address': address,
    'longitude': longitude,
    'latitude': latitude,
    'photo_location': photoLocation,
  };
}
