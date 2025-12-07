import 'app_user.dart';

class AuthPayload {
  const AuthPayload({
    required this.token,
    required this.user,
    required this.defaultAccountId,
    this.businessName,
    this.currency,
  });

  final String token;
  final AppUser user;
  final int defaultAccountId;
  final String? businessName;
  final String? currency;

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(
      token: json['token'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      defaultAccountId: (json['defaultAccountId'] ?? json['accountId']) as int,
      businessName: (json['business']?['name'] ?? json['businessName']) as String?,
      currency: (json['business']?['currency'] ?? json['currency']) as String?,
    );
  }
}
