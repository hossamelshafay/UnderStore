import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'home_repo.dart';

class HomeRepoImp implements HomeRepo {
  static const String _baseUrl = 'https://fakestoreapi.com'; /// api

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
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/category/$category'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/categories'),
      );
      if (response.statusCode == 200) {
        return List<String>.from(json.decode(response.body));
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
