import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gaveliste_app/google_login.dart';
import 'package:gaveliste_app/screens/group.dart';
import 'package:gaveliste_app/screens/wish.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class ApiClient {
  late final String _baseUrl;
  late final Map<String, String> _headers;

  ApiClient() {
    String? baseUrl = dotenv.env['API_URL'];
    if (baseUrl == null) {
      throw const FormatException("Missing env variable API_URL");
    }
    _baseUrl = baseUrl;
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<Response> login(GoogleSignInAccount? account) async {
    if (account == null) {
      throw const HttpException("Unable to sign in google account");
    }
    GoogleSignInAuthentication auth = await account.authentication;

    Uri uri = Uri.parse("$_baseUrl/appLogin");
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode(account.toJson(auth.accessToken)));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to create or retrieve user");
    }
    if (auth.accessToken != null) {
      _headers['Authorization'] = "Bearer ${auth.accessToken!}";
    }
    return res;
  }

  Future<List<T>> fetch<T>(String endpoint, FromJson<T> fromJson) async {
    Uri uri = Uri.parse("$_baseUrl/$endpoint");
    Response res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw const HttpException("Unable to fetch");
    }
    Iterable l = json.decode(res.body);
    return List<T>.from(l.map((model) => fromJson(model)));
  }

  Future<List<Group>> groups() async {
    return fetch<Group>("groups", Group.fromJson);
  }

  Future<List<Wish>> wishes() async {
    return fetch<Wish>("wishes", Wish.fromJson);
  }
}
