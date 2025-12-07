import 'app_user.dart';

class ProfileSnapshot {
  const ProfileSnapshot({
    required this.user,
    required this.accountId,
    this.businessName,
    this.currency,
  });

  final AppUser user;
  final int accountId;
  final String? businessName;
  final String? currency;

  factory ProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return ProfileSnapshot(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      accountId: (json['defaultAccountId'] ?? json['accountId']) as int,
      businessName: (json['business']?['name'] ?? json['businessName']) as String?,
      currency: (json['business']?['currency'] ?? json['currency']) as String?,
    );
  }
}
