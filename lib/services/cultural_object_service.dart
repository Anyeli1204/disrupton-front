import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cultural_object.dart';
import '../models/cultural_agent.dart';
import '../models/product.dart';
class CulturalObjectService {
  final String baseUrl;

  CulturalObjectService(this.baseUrl);

  Future<List<CulturalObject>> fetchCulturalObjects() async {
    final response = await http.get(Uri.parse('$baseUrl/api/cultural-objects'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => CulturalObject.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cultural objects: ${response.statusCode}');
    }
  }

  Future<List<CulturalAgent>> fetchCulturalAgents() async {
    final response = await http.get(Uri.parse('$baseUrl/api/cultural-agents'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => CulturalAgent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cultural agents: ${response.statusCode}');
    }
  }

  // Other methods for interacting with cultural objects API can be added here

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}