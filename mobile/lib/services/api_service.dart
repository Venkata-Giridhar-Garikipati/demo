import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/internship.dart';

class ApiService {
  // Backend URL configuration
  // For Web (Chrome): http://localhost:5000 or http://127.0.0.1:5000
  // For Android emulator: http://10.0.2.2:5000
  // For physical device: http://YOUR_COMPUTER_IP:5000
  // For production: https://your-domain.com
  static const String baseUrl = 'http://localhost:5000';

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

  // NEW: Resume upload functionality (works on both mobile and web)
  Future<Map<String, dynamic>> uploadResume(List<int> fileBytes, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/resume/upload'),
      );

      // Use bytes directly (works on both web and mobile)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response body
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        // Extract error message from backend response
        String errorMessage = responseData['error'] ?? 'Failed to upload resume';
        String? details = responseData['details'];
        
        if (details != null) {
          errorMessage = '$errorMessage: $details';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Re-throw if it's already an Exception with our custom message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Resume upload error: $e');
    }
  }

  // NEW: Parse resume text (alternative to file upload)
  Future<Map<String, dynamic>> parseResumeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resume/parse-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to parse resume text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Resume parsing error: $e');
    }
  }

  // Get available sectors (for dynamic loading)
  Future<List<String>> getSectors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sectors'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['sectors']);
      } else {
        throw Exception('Failed to load sectors');
      }
    } catch (e) {
      throw Exception('Sectors loading error: $e');
    }
  }

  // Get available skills (for dynamic loading)
  Future<List<String>> getSkills() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/skills'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['skills']);
      } else {
        throw Exception('Failed to load skills');
      }
    } catch (e) {
      throw Exception('Skills loading error: $e');
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}