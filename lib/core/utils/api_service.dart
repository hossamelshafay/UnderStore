import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  static const defaultBaseUrl = 'https://fakestoreapi.com';

  ApiService({this.baseUrl = defaultBaseUrl});

  Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }

  Future<Map<String, dynamic>> get({required String endpoint}) async {
    try {
      final response = await http.get(_buildUri(endpoint));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        _buildUri(endpoint),
        body: data != null ? json.encode(data) : null,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': 'success', 'data': json.decode(response.body)};
      } else {
        return {
          'status': 'error',
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        _buildUri(endpoint),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete({required String endpoint}) async {
    try {
      final response = await http.delete(_buildUri(endpoint));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
