import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data.dart';

class ApiService {
  static const String apiUrl = 'https://dummyjson.com/products';

  // Mengambil semua produk (endpoint: /products)
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List products = data['products'];

      // Cukup satu baris
      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Mengambil satu produk (endpoint: /products/{id})
  static Future<Product> getSingleProduct(int productId) async {
    final response = await http.get(Uri.parse('$apiUrl/$productId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product details');
    }
  }
}
