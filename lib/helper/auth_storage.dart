import 'dart:async';
import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:aad_oauth/model/token.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static AuthStorage shared = AuthStorage();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _tokenIdentifier;

  AuthStorage({String tokenIdentifier = 'Token'})
      : _tokenIdentifier = tokenIdentifier;

  Future<void> saveTokenToCache(Token token) async {
    var data = Token.toJsonMap(token);
    var json = jsonEncode(data);
    await _secureStorage.write(key: _tokenIdentifier, value: json);
  }

  Future<Token> loadTokenFromCache() async {
    var emptyToken = Token();
    var json = await _secureStorage.read(key: _tokenIdentifier);
    if (json == null) return emptyToken;
    try {
      var data = jsonDecode(json);
      return _getTokenFromMap(data);
    } catch (exception) {
      print(exception);
      return emptyToken;
    }
  }

  Token _getTokenFromMap(Map<String, dynamic> data) =>
      Token.fromJson(data);

  Future clear() async {
    await _secureStorage.delete(key: _tokenIdentifier);
  }
}
