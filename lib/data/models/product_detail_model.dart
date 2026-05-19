import 'dart:convert';

import '../../domain/entities/product_detail.dart';

class ProductDetailModel extends ProductDetail {
  const ProductDetailModel({
    required super.id,
    required super.name,
    super.description,
    super.productImage,
    super.categoryName,
    super.price,
    super.mrp,
    super.purchasePrice,
    super.taxRate,
    super.gstName,
    super.hsnCode,
    super.slug,
    super.status,
    super.unitName,
    super.barcode,
    super.currentStockCount,
    super.isOutOfStock,
    super.wantToManageStock,
    super.lowStockAlertQty,
    super.createdAt,
    super.updatedAt,
    super.isFavorite,
  });

  factory ProductDetailModel.fromJson(
    Map<String, dynamic> json, {
    bool isFavorite = false,
  }) {
    final category = json['productCategory'] as Map<String, dynamic>?;
    final gst = json['gst'] as Map<String, dynamic>?;
    final unit = json['unitDetail'] as Map<String, dynamic>?;

    double? toDouble(dynamic v) =>
        v == null ? null : (v as num).toDouble();

    return ProductDetailModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unnamed',
      description: _str(json['description']),
      productImage: json['productImage'] as String?,
      categoryName: category?['name'] as String?,
      price: toDouble(json['price']),
      mrp: toDouble(json['mrp']),
      purchasePrice: toDouble(json['purchasePrice']),
      taxRate: toDouble(json['taxRate']),
      gstName: gst?['gst_name'] as String?,
      hsnCode: _str(json['hsnCode']),
      slug: json['slug'] as String?,
      status: json['status'] as String?,
      unitName: unit?['unit_name'] as String?,
      barcode: json['barcode'] as String?,
      currentStockCount: json['currentStockCount'] as int?,
      isOutOfStock: json['isOutOfStock'] as bool?,
      wantToManageStock: json['wantToManageStock'] as bool?,
      lowStockAlertQty: json['lowStockAlertQty'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isFavorite: isFavorite,
    );
  }

  factory ProductDetailModel.fromRawJson(String raw, {bool isFavorite = false}) {
    return ProductDetailModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      isFavorite: isFavorite,
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
