class ApiConstants {
  static const baseUrl = 'https://app.apnabillbook.com/api';
  static const storeId = '4ad3de84-bcaa-4bb2-9eb9-1846844e3314';
  static const pageSize = 10;

  static String productsUrl(int page) =>
      '$baseUrl/product?storeId=$storeId&page=$page&pageSize=$pageSize';
}
