import '../entities/data_load_source.dart';
import '../entities/product.dart';
import '../entities/product_detail.dart';

abstract class ProductRepository {
  DataLoadSource? get lastLoadSource;

  Future<List<Product>> getProducts({required int page, bool forceRefresh});

  Future<void> toggleFavorite(int productId, bool isFavorite);

  Future<List<Product>> getFavorites();

  Future<ProductDetail?> getProductDetail(int id);

  Future<bool> hasLocalData();

  Future<int> getTotalPages();
}
