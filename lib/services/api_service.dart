import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// API Service for communicating with the backend
/// Handles all HTTP requests and token management
class ApiService {
  // Base URL is configured in lib/config/api_config.dart
  static const String _baseUrl = ApiConfig.BASE_URL;
  
  String? _token;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Initialize and load stored token
  Future<void> init() async {
    _token = await getToken();
  }

  /// Save token to local storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Get token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Clear token (logout)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Get headers with authentication
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Handle API errors
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is SocketException) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } else if (error is http.ClientException) {
      return {
        'success': false,
        'message': 'Cannot connect to server. Make sure the backend is running.',
      };
    } else {
      return {
        'success': false,
        'message': 'An error occurred: ${error.toString()}',
      };
    }
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Admin Signup
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/signup'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token
        if (data['data']?['token'] != null) {
          await saveToken(data['data']['token']);
        }
        return data;
      } else {
        return data;
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Admin Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token
        if (data['data']?['token'] != null) {
          await saveToken(data['data']['token']);
        }
        return data;
      } else {
        return data;
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get Admin Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/profile'),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== VACCINATION RECORDS ENDPOINTS ====================

  /// Create Vaccination Record
  Future<Map<String, dynamic>> createVaccinationRecord(
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/vaccinations'),
        headers: _getHeaders(),
        body: jsonEncode(record),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get All Vaccination Records
  Future<Map<String, dynamic>> getVaccinationRecords({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    try {
      var url = '$_baseUrl/admin/vaccinations?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get Single Vaccination Record
  Future<Map<String, dynamic>> getVaccinationRecord(String recordId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/vaccinations/$recordId'),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update Vaccination Record
  Future<Map<String, dynamic>> updateVaccinationRecord(
    String recordId,
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/vaccinations/$recordId'),
        headers: _getHeaders(),
        body: jsonEncode(record),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete Vaccination Record
  Future<Map<String, dynamic>> deleteVaccinationRecord(String recordId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/vaccinations/$recordId'),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get Vaccination Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/vaccinations/stats/summary'),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Search Vaccination Records
  Future<Map<String, dynamic>> searchRecords(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/vaccinations/search?query=$query'),
        headers: _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return _handleError(e);
    }
  }
}
