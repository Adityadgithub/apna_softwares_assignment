import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsPage {
  GetProductsPage(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call(int page, {bool forceRefresh = false}) {
    return _repository.getProducts(page: page, forceRefresh: forceRefresh);
  }
}
