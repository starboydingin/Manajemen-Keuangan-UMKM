import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _accountKey = 'account_id';
  static const _fullNameKey = 'user_full_name';
  static const _emailKey = 'user_email';
  static const _businessKey = 'business_name';
  static const _currencyKey = 'business_currency';
  static const _profileOverridesKey = 'profile_overrides';

  Future<void> saveSession({
    required String token,
    required int accountId,
    required String fullName,
    required String email,
    String? businessName,
    String? currency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _accountKey, value: '$accountId');
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_emailKey, email);
    if (businessName != null) {
      await prefs.setString(_businessKey, businessName);
    } else {
      await prefs.remove(_businessKey);
    }
    if (currency != null) {
      await prefs.setString(_currencyKey, currency);
    } else {
      await prefs.remove(_currencyKey);
    }
  }

  Future<Map<String, dynamic>?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _secureStorage.read(key: _tokenKey);
    final accountIdRaw = await _secureStorage.read(key: _accountKey);
    final accountId = accountIdRaw != null ? int.tryParse(accountIdRaw) : null;
    if (token == null || accountId == null) return null;
    return {
      'token': token,
      'accountId': accountId,
      'fullName': prefs.getString(_fullNameKey),
      'email': prefs.getString(_emailKey),
      'businessName': prefs.getString(_businessKey),
      'currency': prefs.getString(_currencyKey),
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _accountKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_businessKey);
    await prefs.remove(_currencyKey);
  }

  Future<void> updateProfile({required String email, required String fullName, String? businessName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, fullName);
    if (businessName == null || businessName.isEmpty) {
      await prefs.remove(_businessKey);
    } else {
      await prefs.setString(_businessKey, businessName);
    }
    await saveProfileOverride(email: email, fullName: fullName, businessName: businessName);
  }

  Future<void> saveProfileOverride({
    required String email,
    required String fullName,
    String? businessName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileOverridesKey);
    final Map<String, dynamic> overrides = raw != null
      ? Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>)
      : <String, dynamic>{};
    overrides[email] = {
      'fullName': fullName,
      'businessName': businessName ?? '',
    };
    await prefs.setString(_profileOverridesKey, jsonEncode(overrides));
  }

  Future<Map<String, String?>?> readProfileOverride(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileOverridesKey);
    if (raw == null) return null;
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);
    final override = data[email];
    if (override is! Map<String, dynamic>) return null;
    return {
      'fullName': override['fullName'] as String?,
      'businessName': override['businessName'] as String?,
    };
  }

  Future<void> clearProfileOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileOverridesKey);
  }
}
