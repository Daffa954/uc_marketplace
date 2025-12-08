part of 'model.dart';

class PreOrderMenuModel {
  final int? preOrderMenuId;
  final int? preOrderId;
  final int? menuId;

  // Optional: Untuk menampung detail menu jika Anda melakukan query Join
  // Contoh: .select('*, menus(*)')
  final MenuModel? menu;

  PreOrderMenuModel({
    this.preOrderMenuId,
    this.preOrderId,
    this.menuId,
    this.menu,
  });

  factory PreOrderMenuModel.fromJson(Map<String, dynamic> json) {
    return PreOrderMenuModel(
      preOrderMenuId: json['pre_order_menu_id'],
      preOrderId: json['pre_order_id'],
      menuId: json['menu_id'],
      // Logic untuk mengambil data Menu jika di-include dalam query
      menu: json['menus'] != null 
          ? MenuModel.fromJson(json['menus']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'pre_order_id': preOrderId,
    'menu_id': menuId,
    // pre_order_menu_id biasanya auto-generated di DB
  };
}