part of 'model.dart';

class GeneralCategoryModel {
  final int? generalCategoryId;
  final String? name;
  final String? imageUrl;

  GeneralCategoryModel({this.generalCategoryId, this.name, this.imageUrl});

  factory GeneralCategoryModel.fromJson(Map<String, dynamic> json) {
    return GeneralCategoryModel(
      generalCategoryId: json['general_category_id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
  Map<String, dynamic> toJson() => {
    'general_category_id': generalCategoryId,
    'name': name,
    'image_url': imageUrl,
  };
}
