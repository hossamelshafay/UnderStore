import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../home/data/models/product_model.dart';
import 'search_repo.dart';

class SearchRepoImp implements SearchRepo {
  static const String _baseUrl = 'https://fakestoreapi.com';

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Get all products
      final products = await getAllProducts();

      // If query is empty, return empty list
      if (query.isEmpty) {
        return [];
      }

      // Filter products based on query
      final lowerQuery = query.toLowerCase();
      return products.where((product) {
        return product.title.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
