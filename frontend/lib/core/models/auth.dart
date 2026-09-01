class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userId;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    required this.expiresIn,
    required this.userId,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] as int,
      userId: json['user_id'] as String,
    );
  }
}

class ProfileResponse {
  final String id;
  final String? displayName;
  final String? avatarUrl;

  ProfileResponse({
    required this.id,
    this.displayName,
    this.avatarUrl,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class UserMeResponse {
  final String id;
  final String email;
  final bool isActive;
  final ProfileResponse? profile;

  UserMeResponse({
    required this.id,
    required this.email,
    required this.isActive,
    this.profile,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    return UserMeResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      profile: json['profile'] != null
          ? ProfileResponse.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}
