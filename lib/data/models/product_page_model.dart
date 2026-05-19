import 'product_model.dart';

class ProductPageModel {
  ProductPageModel({
    required this.products,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });

  final List<ProductModel> products;
  final int totalPages;
  final int currentPage;
  final int totalItems;

  factory ProductPageModel.fromJson(Map<String, dynamic> json, int page) {
    final data = json['data'] as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;

    return ProductPageModel(
      products: list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>, page))
          .toList(),
      totalPages: data['totalPages'] as int? ?? 1,
      currentPage: data['currentPage'] as int? ?? page,
      totalItems: data['totalItems'] as int? ?? list.length,
    );
  }
}
