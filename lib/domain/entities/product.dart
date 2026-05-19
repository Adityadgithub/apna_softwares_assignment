class Product {
  const Product({
    required this.id,
    required this.name,
    this.price,
    this.mrp,
    this.imageUrl,
    this.categoryName,
    this.isFavorite = false,
    this.pageNumber = 1,
  });

  final int id;
  final String name;
  final double? price;
  final double? mrp;
  final String? imageUrl;
  final String? categoryName;
  final bool isFavorite;
  final int pageNumber;

  Product copyWith({
    String? name,
    double? price,
    double? mrp,
    String? imageUrl,
    String? categoryName,
    bool? isFavorite,
    int? pageNumber,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryName: categoryName ?? this.categoryName,
      isFavorite: isFavorite ?? this.isFavorite,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}
