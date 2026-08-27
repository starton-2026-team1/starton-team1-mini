class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      accessTokenExpiresIn: (json['access_token_expires_in'] as num).toInt(),
      refreshTokenExpiresIn: (json['refresh_token_expires_in'] as num).toInt(),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int accessTokenExpiresIn;
  final int refreshTokenExpiresIn;
}
