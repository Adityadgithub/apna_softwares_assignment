import '../../core/errors/app_exception.dart';
import '../../domain/entities/data_load_source.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../../services/connectivity_service.dart';
import '../datasources/local/favorite_local_ds.dart';
import '../datasources/local/page_cache_local_ds.dart';
import '../datasources/local/product_local_ds.dart';
import '../datasources/local/sync_queue_local_ds.dart';
import '../datasources/remote/product_remote_ds.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
    required FavoriteLocalDataSource favorites,
    required PageCacheLocalDataSource pageCache,
    required SyncQueueLocalDataSource syncQueue,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _favorites = favorites,
        _pageCache = pageCache,
        _syncQueue = syncQueue,
        _connectivity = connectivity;

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final FavoriteLocalDataSource _favorites;
  final PageCacheLocalDataSource _pageCache;
  final SyncQueueLocalDataSource _syncQueue;
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
    final cacheValid = await _local.isPageCacheValid(page);
    final hasPage = await _pageCache.hasPage(page);

    if (online && (forceRefresh || !cacheValid || !hasPage)) {
      try {
        final remotePage = await _remote.fetchPage(page);
        _totalPages = remotePage.totalPages;
        await _local.saveProducts(remotePage.products, page);
        _totalPages = remotePage.totalPages;
        await _pageCache.savePage(
          page,
          remotePage.products.length,
          remotePage.totalPages,
        );
        _lastLoadSource = DataLoadSource.api;
        return _mergeFavorites(remotePage.products);
      } on NetworkException {
        if (hasPage) {
          _lastLoadSource = DataLoadSource.localCache;
          return _local.getByPage(page);
        }
        rethrow;
      }
    }

    if (hasPage || await _local.hasAny()) {
      _lastLoadSource = DataLoadSource.localCache;
      if (page == 1 && !hasPage) {
        return _local.getAllOrdered();
      }
      return _local.getByPage(page);
    }

    if (!online) {
      throw NetworkException('No cached data available offline');
    }

    return [];
  }

  @override
  Future<List<Product>> getFavorites() => _local.getFavorites();

  @override
  Future<ProductDetail?> getProductDetail(int id) => _local.getDetailById(id);

  @override
  Future<void> toggleFavorite(int productId, bool isFavorite) async {
    await _favorites.setFavorite(productId, isFavorite);
    await _syncQueue.enqueue(productId, isFavorite);
  }

  @override
  Future<bool> hasLocalData() => _local.hasAny();

  @override
  Future<int> getTotalPages() async {
    final cached = await _pageCache.getTotalPages();
    return cached ?? _totalPages;
  }

  Future<List<Product>> _mergeFavorites(List<ProductModel> items) async {
    final result = <Product>[];
    for (final p in items) {
      final fav = await _favorites.isFavorite(p.id);
      result.add(p.copyWith(isFavorite: fav));
    }
    return result;
  }
}
