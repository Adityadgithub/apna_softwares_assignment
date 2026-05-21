import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import 'models/product_page_model.dart';

class ProductApi {
  ProductApi([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ProductPageModel> fetchPage(int page) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.productsUrl(page)),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw NetworkException('Network error', code: response.statusCode);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['status'] != true) {
        throw NetworkException(body['message']?.toString() ?? 'Request failed');
      }

      return ProductPageModel.fromJson(body, page);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
