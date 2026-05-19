import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'presentation/bindings/favorites_binding.dart';
import 'presentation/bindings/home_binding.dart';
import 'presentation/bindings/initial_binding.dart';
import 'presentation/bindings/product_detail_binding.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/product_detail_page.dart';

class ApnaApp extends StatelessWidget {
  const ApnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Apna Products',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/favorites',
          page: () => const FavoritesPage(),
          binding: FavoritesBinding(),
        ),
        GetPage(
          name: '/product/detail',
          page: () => const ProductDetailPage(),
          binding: ProductDetailBinding(),
        ),
      ],
      initialRoute: '/',
    );
  }
}
