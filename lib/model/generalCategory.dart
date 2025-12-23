part of 'model.dart';

class GeneralCategoryModel {
  final int? generalCategoryId;
  final String? name;
  final String? imageUrl;

  GeneralCategoryModel({this.generalCategoryId, this.name, this.imageUrl});

  factory GeneralCategoryModel.fromJson(Map<String, dynamic> json) {
    return GeneralCategoryModel(
      generalCategoryId: json['Generalcategory_id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}
