import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/internship.dart';

class ApiService {
  // Change this to your backend URL
  // For Android emulator: http://10.0.2.2:5000
  // For physical device: http://YOUR_COMPUTER_IP:5000
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<List<Internship>> getRecommendations({
    required String education,
    required List<String> skills,
    required String sector,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'education': education,
          'skills': skills,
          'sector': sector,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> recommendationsJson = data['recommendations'];
          return recommendationsJson
              .map((json) => Internship.fromJson(json))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}