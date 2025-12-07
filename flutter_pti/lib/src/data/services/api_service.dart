import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/auth_payload.dart';
import '../models/balance_snapshot.dart';
import '../models/category_model.dart';
import '../models/profile_snapshot.dart';
import '../models/report_summary.dart';
import '../models/transaction_input.dart';
import '../models/transaction_model.dart';

class ApiService {
  ApiService({required String baseUrl}) : _client = ApiClient(baseUrl: baseUrl);

  final ApiClient _client;

  Future<AuthPayload> register({
    required String fullName,
    required String email,
    required String password,
    required String businessName,
    String currency = 'IDR',
  }) async {
    final response = await _client.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'businessName': businessName,
      'currency': currency,
    });
    return AuthPayload.fromJson(_unwrap(response));
  }

  Future<AuthPayload> login({required String email, required String password}) async {
    final response = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthPayload.fromJson(_unwrap(response));
  }

  Future<BalanceSnapshot> fetchBalance({required String token, required int accountId}) async {
    final response = await _client.get('/accounts/$accountId/balance', headers: _authHeader(token));
    return BalanceSnapshot.fromJson(_unwrap(response));
  }

  Future<List<TransactionModel>> fetchTransactions({
    required String token,
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) async {
    final response = await _client.get(
      '/accounts/$accountId/transactions',
      headers: _authHeader(token),
      query: {
        'startDate': startDate?.toIso8601String().split('T').first,
        'endDate': endDate?.toIso8601String().split('T').first,
        'categoryId': categoryId,
      },
    );
    final data = _unwrap(response) as List<dynamic>;
    return data.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CategoryModel>> fetchCategories({required String token, required int accountId}) async {
    final response = await _client.get('/accounts/$accountId/categories', headers: _authHeader(token));
    final data = _unwrap(response) as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createTransaction({
    required String token,
    required int accountId,
    required TransactionInput input,
  }) async {
    await _client.post(
      '/accounts/$accountId/transactions',
      input.toJson(),
      headers: _authHeader(token),
    );
  }

  Future<ReportSummary> fetchReport({
    required String token,
    required int accountId,
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    final response = await _client.get(
      '/accounts/$accountId/reports',
      headers: _authHeader(token),
      query: {
        'period': period,
        'startDate': startDate?.toIso8601String().split('T').first,
        'endDate': endDate?.toIso8601String().split('T').first,
        'month': month,
        'year': year,
      },
    );
    final data = _unwrap(response) as Map<String, dynamic>;
    return ReportSummary.fromJson(data);
  }

  Future<ProfileSnapshot> fetchProfile({required String token}) async {
    final response = await _client.get('/profile', headers: _authHeader(token));
    final data = _unwrap(response) as Map<String, dynamic>;
    return ProfileSnapshot.fromJson(data);
  }

  Future<ProfileSnapshot> updateProfile({
    required String token,
    required String fullName,
    String? businessName,
  }) async {
    final response = await _client.put(
      '/profile',
      {
        'fullName': fullName,
        'businessName': businessName,
      },
      headers: _authHeader(token),
    );
    final data = _unwrap(response) as Map<String, dynamic>;
    return ProfileSnapshot.fromJson(data);
  }

  Future<void> logout({required String token}) async {
    await _client.post('/auth/logout', {}, headers: _authHeader(token));
  }

  Map<String, String> _authHeader(String token) => {'Authorization': 'Bearer $token'};

  dynamic _unwrap(Map<String, dynamic> body) {
    if (body.containsKey('data')) return body['data'];
    if (body.containsKey('status') && body['status'] == 'success' && body.containsKey('data')) {
      return body['data'];
    }
    throw ApiException('Respon tidak dikenali dari server');
  }

  void dispose() {
    _client.dispose();
  }
}
