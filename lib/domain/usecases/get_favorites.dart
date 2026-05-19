import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetFavorites {
  GetFavorites(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call() => _repository.getFavorites();
}
