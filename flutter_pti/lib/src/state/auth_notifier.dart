import 'package:flutter/material.dart';

import '../data/api/api_exception.dart';
import '../data/models/app_user.dart';
import '../data/models/auth_payload.dart';
import '../data/services/api_service.dart';
import '../data/storage/session_storage.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    required this.apiBaseUrl,
    ApiService? apiService,
    SessionStorage? storage,
  })  : _apiService = apiService ?? ApiService(baseUrl: apiBaseUrl),
        _storage = storage ?? SessionStorage();

  final String apiBaseUrl;
  final ApiService _apiService;
  final SessionStorage _storage;

  ApiService get api => _apiService;

  bool _initializing = true;
  bool get isInitializing => _initializing;

  bool _loading = false;
  bool get isLoading => _loading;

  AppUser? _user;
  AppUser? get user => _user;

  String? _token;
  int? _accountId;
  String? _businessName;
  String? _currency;

  AuthSession? get session {
    if (_token == null || _accountId == null || _user == null) return null;
    return AuthSession(
      token: _token!,
      accountId: _accountId!,
      user: _user!,
      businessName: _businessName,
      currency: _currency,
    );
  }

  Future<void> initialize() async {
    final cached = await _storage.readSession();
    if (cached != null) {
      _token = cached['token'] as String;
      _accountId = cached['accountId'] as int;
      _user = AppUser(
        id: -1,
        email: (cached['email'] ?? '') as String,
        fullName: (cached['fullName'] ?? 'Pengguna') as String,
      );
      _businessName = cached['businessName'] as String?;
      _currency = cached['currency'] as String?;
    }
    _initializing = false;
    notifyListeners();
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      final payload = await _apiService.login(email: email, password: password);
      await _persistPayload(payload);
      await _applyPayload(payload);
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Gagal masuk. Coba lagi nanti.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String businessName,
  }) async {
    try {
      _setLoading(true);
      final payload = await _apiService.register(
        fullName: fullName,
        email: email,
        password: password,
        businessName: businessName,
      );
      await _persistPayload(payload);
      await _applyPayload(payload);
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Registrasi gagal. Coba lagi nanti.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    final tokenToRevoke = _token;
    try {
      if (tokenToRevoke != null) {
        await _apiService.logout(token: tokenToRevoke);
      }
    } catch (_) {
      // Ignore network failure on logout
    } finally {
      _token = null;
      _accountId = null;
      _user = null;
      _businessName = null;
      await _storage.clear();
      notifyListeners();
    }
  }

  Future<String?> updateProfile({required String fullName, String? businessName}) async {
    if (_user == null || _token == null) {
      return 'Sesi kedaluwarsa. Silakan masuk kembali.';
    }
    final sanitizedName = fullName.trim();
    if (sanitizedName.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    final sanitizedBusiness = businessName?.trim();
    final payloadBusiness = (sanitizedBusiness?.isEmpty ?? true) ? null : sanitizedBusiness;
    try {
      final snapshot = await _apiService.updateProfile(
        token: _token!,
        fullName: sanitizedName,
        businessName: payloadBusiness,
      );
      _user = snapshot.user;
      _businessName = snapshot.businessName;
      _currency = snapshot.currency ?? _currency;
      _accountId = snapshot.accountId;
      await _storage.updateProfile(
        email: _user!.email,
        fullName: _user!.fullName,
        businessName: _businessName,
      );
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Gagal memperbarui profil. Coba lagi.';
    }
  }

  Future<void> _applyPayload(AuthPayload payload) async {
    _token = payload.token;
    _accountId = payload.defaultAccountId;
    _businessName = payload.businessName;
    _currency = payload.currency;
    _user = payload.user;
    await _applyProfileOverrides();
    notifyListeners();
  }

  Future<void> _applyProfileOverrides() async {
    if (_user == null) return;
    final overrides = await _storage.readProfileOverride(_user!.email);
    if (overrides == null) return;
    final overrideName = overrides['fullName']?.trim();
    final overrideBusiness = overrides['businessName']?.trim();
    var changed = false;
    if (overrideName != null && overrideName.isNotEmpty && _user!.fullName != overrideName) {
      _user = AppUser(id: _user!.id, email: _user!.email, fullName: overrideName);
      changed = true;
    }
    if (overrideBusiness != null) {
      _businessName = overrideBusiness.isEmpty ? null : overrideBusiness;
      changed = true;
    }
    if (changed) {
      await _storage.updateProfile(email: _user!.email, fullName: _user!.fullName, businessName: _businessName);
    }
  }

  Future<void> _persistPayload(AuthPayload payload) async {
    await _storage.saveSession(
      token: payload.token,
      accountId: payload.defaultAccountId,
      fullName: payload.user.fullName,
      email: payload.user.email,
      businessName: payload.businessName,
      currency: payload.currency,
    );
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.accountId,
    required this.user,
    this.businessName,
    this.currency,
  });

  final String token;
  final int accountId;
  final AppUser user;
  final String? businessName;
  final String? currency;
}
