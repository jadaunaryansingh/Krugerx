import 'package:isar_community/isar.dart';

part 'auth_models.g.dart';

@collection
class AuthSession {
  Id id = Isar.autoIncrement;

  String? accessToken;
  String? refreshToken;
  int? expiresIn;
  String? userId;
  String? email;
  String? displayName;
  String? avatarUrl;
  String? authProvider;
}
