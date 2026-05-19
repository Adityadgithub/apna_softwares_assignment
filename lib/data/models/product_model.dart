import 'dart:convert';

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.price,
    super.mrp,
    super.imageUrl,
    super.categoryName,
    super.isFavorite,
    super.pageNumber,
    this.rawJson,
  });

  final String? rawJson;

  factory ProductModel.fromJson(Map<String, dynamic> json, int page) {
    final category = json['productCategory'] as Map<String, dynamic>?;
    final price = json['price'];
    final mrp = json['mrp'];

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unnamed',
      price: price == null ? null : (price as num).toDouble(),
      mrp: mrp == null ? null : (mrp as num).toDouble(),
      imageUrl: json['productImage'] as String?,
      categoryName: category?['name'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      pageNumber: page,
      rawJson: jsonEncode(json),
    );
  }

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'price': price,
        'mrp': mrp,
        'image_url': imageUrl,
        'category_name': categoryName,
        'page_number': pageNumber,
        'is_favorite_remote': isFavorite,
      };

  factory ProductModel.fromDb(
    Map<String, dynamic> row, {
    required bool isFavorite,
  }) {
    return ProductModel(
      id: row['id'] as int,
      name: row['name'] as String,
      price: row['price'] as double?,
      mrp: row['mrp'] as double?,
      imageUrl: row['image_url'] as String?,
      categoryName: row['category_name'] as String?,
      isFavorite: isFavorite,
      pageNumber: row['page_number'] as int,
    );
  }
}
