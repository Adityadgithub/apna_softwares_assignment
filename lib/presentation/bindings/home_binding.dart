import 'package:get/get.dart';

import '../controllers/product_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
  }
}
