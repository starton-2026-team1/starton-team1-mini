import 'auth_tokens.dart';
import 'auth_user.dart';

class AuthSession {
  const AuthSession({required this.tokens, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      tokens: AuthTokens.fromJson(json),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final AuthTokens tokens;
  final AuthUser user;
}
