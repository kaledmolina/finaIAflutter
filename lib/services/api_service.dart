import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ApiService {
  final String _baseUrl = "https://finanzasia.kaledcloud.tech/api/v1";
  String? _token;

  Future<void> _loadToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }
  
  Future<void> logout() async {
    await _loadToken();
    if (_token == null) return;
    await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['token'] != null) {
        await _saveToken(data['token']);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return response.statusCode == 201;
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    await _loadToken();
    if (_token == null) throw Exception('Token no encontrado');
    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los datos del dashboard');
    }
  }

  Future<bool> addMonthlyIncome(String amount) async {
    await _loadToken();
    if (_token == null) return false;
    final response = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      body: jsonEncode({'description': 'Ingreso Mensual', 'amount': amount, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'type': 'ingreso'}),
    );
    return response.statusCode == 201;
  }

  Future<List<dynamic>> getTransactions() async {
    await _loadToken();
    if (_token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/transactions'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getCategories() async {
    await _loadToken();
    if (_token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['data'] as List<dynamic>;
    }
    return [];
  }

  Future<bool> storeTransaction(Map<String, dynamic> transactionData) async {
    await _loadToken();
    if (_token == null) return false;
    final response = await http.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      body: jsonEncode(transactionData),
    );
    return response.statusCode == 201;
  }

  Future<bool> storeCategory(Map<String, dynamic> categoryData) async {
    await _loadToken();
    if (_token == null) return false;
    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      body: jsonEncode(categoryData),
    );
    return response.statusCode == 201;
  }

  // --- NUEVOS MÉTODOS PARA SUGERENCIAS ---
  Future<List<dynamic>> getCategorySuggestions() async {
    await _loadToken();
    if (_token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/categories/suggestions'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<bool> storeSelectedSuggestions(List<dynamic> categories) async {
    await _loadToken();
    if (_token == null) return false;
    final response = await http.post(
      Uri.parse('$_baseUrl/categories/suggestions'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
      body: jsonEncode({'categories': categories}),
    );
    return response.statusCode == 201;
  }
}
