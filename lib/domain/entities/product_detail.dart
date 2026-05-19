class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.name,
    this.description,
    this.productImage,
    this.categoryName,
    this.price,
    this.mrp,
    this.purchasePrice,
    this.taxRate,
    this.gstName,
    this.hsnCode,
    this.slug,
    this.status,
    this.unitName,
    this.barcode,
    this.currentStockCount,
    this.isOutOfStock,
    this.wantToManageStock,
    this.lowStockAlertQty,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String? description;
  final String? productImage;
  final String? categoryName;
  final double? price;
  final double? mrp;
  final double? purchasePrice;
  final double? taxRate;
  final String? gstName;
  final String? hsnCode;
  final String? slug;
  final String? status;
  final String? unitName;
  final String? barcode;
  final int? currentStockCount;
  final bool? isOutOfStock;
  final bool? wantToManageStock;
  final int? lowStockAlertQty;
  final String? createdAt;
  final String? updatedAt;
  final bool isFavorite;

  ProductDetail copyWith({bool? isFavorite}) {
    return ProductDetail(
      id: id,
      name: name,
      description: description,
      productImage: productImage,
      categoryName: categoryName,
      price: price,
      mrp: mrp,
      purchasePrice: purchasePrice,
      taxRate: taxRate,
      gstName: gstName,
      hsnCode: hsnCode,
      slug: slug,
      status: status,
      unitName: unitName,
      barcode: barcode,
      currentStockCount: currentStockCount,
      isOutOfStock: isOutOfStock,
      wantToManageStock: wantToManageStock,
      lowStockAlertQty: lowStockAlertQty,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
