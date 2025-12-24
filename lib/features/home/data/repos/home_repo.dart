import '../models/product_model.dart';

abstract class HomeRepo {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<String>> getCategories();
}
