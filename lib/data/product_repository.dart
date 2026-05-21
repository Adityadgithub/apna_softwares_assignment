import '../core/errors/app_exception.dart';
import '../services/connectivity_service.dart';
import 'api.dart';
import 'local_store.dart';
import 'models/data_load_source.dart';
import 'models/product.dart';
import 'models/product_detail.dart';
import 'models/product_model.dart';

abstract class ProductRepository {
  DataLoadSource? get lastLoadSource;

  Future<List<Product>> getProducts({required int page, bool forceRefresh});

  Future<void> toggleFavorite(int productId, bool isFavorite);

  Future<List<Product>> getFavorites();

  Future<ProductDetail?> getProductDetail(int id);

  Future<bool> hasLocalData();

  Future<int> getTotalPages();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductApi api,
    required LocalStore store,
    required ConnectivityService connectivity,
  })  : _api = api,
        _store = store,
        _connectivity = connectivity;

  final ProductApi _api;
  final LocalStore _store;
  final ConnectivityService _connectivity;

  int _totalPages = 1;
  DataLoadSource? _lastLoadSource;

  @override
  DataLoadSource? get lastLoadSource => _lastLoadSource;

  @override
  Future<List<Product>> getProducts({
    required int page,
    bool forceRefresh = false,
  }) async {
    final online = await _connectivity.isOnline();
    final cacheValid = await _store.isPageCacheValid(page);
    final hasPage = await _store.hasPage(page);

    if (online && (forceRefresh || !cacheValid || !hasPage)) {
      try {
        final remotePage = await _api.fetchPage(page);
        _totalPages = remotePage.totalPages;
        await _store.saveProducts(remotePage.products, page);
        await _store.savePage(
          page,
          remotePage.products.length,
          remotePage.totalPages,
        );
        _lastLoadSource = DataLoadSource.api;
        return _mergeFavorites(remotePage.products);
      } on NetworkException {
        if (hasPage) {
          _lastLoadSource = DataLoadSource.localCache;
          return _store.getByPage(page);
        }
        rethrow;
      }
    }

    if (hasPage || await _store.hasAny()) {
      _lastLoadSource = DataLoadSource.localCache;
      if (page == 1 && !hasPage) {
        return _store.getAllOrdered();
      }
      return _store.getByPage(page);
    }

    if (!online) {
      throw NetworkException('No cached data available offline');
    }

    return [];
  }

  @override
  Future<List<Product>> getFavorites() => _store.getFavorites();

  @override
  Future<ProductDetail?> getProductDetail(int id) => _store.getDetailById(id);

  @override
  Future<void> toggleFavorite(int productId, bool isFavorite) async {
    await _store.setFavorite(productId, isFavorite);
    await _store.enqueueSync(productId, isFavorite);
  }

  @override
  Future<bool> hasLocalData() => _store.hasAny();

  @override
  Future<int> getTotalPages() async {
    final cached = await _store.getTotalPages();
    return cached ?? _totalPages;
  }

  Future<List<Product>> _mergeFavorites(List<ProductModel> items) async {
    final result = <Product>[];
    for (final p in items) {
      final fav = await _store.isFavorite(p.id);
      result.add(p.copyWith(isFavorite: fav));
    }
    return result;
  }
}
