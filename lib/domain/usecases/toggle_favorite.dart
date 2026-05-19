import '../repositories/product_repository.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final ProductRepository _repository;

  Future<void> call(int productId, bool isFavorite) {
    return _repository.toggleFavorite(productId, isFavorite);
  }
}
