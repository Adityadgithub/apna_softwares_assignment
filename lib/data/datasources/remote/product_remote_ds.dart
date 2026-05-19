import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/product_page_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductPageModel> fetchPage(int page) async {
    try {
      final response = await _dio.get(ApiConstants.productsUrl(page));
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != true) {
        throw NetworkException(body['message']?.toString() ?? 'Request failed');
      }

      return ProductPageModel.fromJson(body, page);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        code: e.response?.statusCode,
      );
    }
  }
}
