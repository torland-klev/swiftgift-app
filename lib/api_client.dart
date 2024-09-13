import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple_platform_interface/authorization_credential.dart';
import 'package:swiftgift_app/auth/google_login.dart';
import 'package:swiftgift_app/main.dart';
import 'package:swiftgift_app/util.dart';

import 'data/group.dart';
import 'data/user.dart';
import 'data/wish.dart';

typedef FromJson<T> = dynamic Function(Map<String, dynamic> json);

Future<T> _fromJsonHandler<T>(
    FromJson<T> fromJson, Map<String, dynamic> json) async {
  var result = fromJson(json);
  if (result is Future<T>) {
    return await result;
  } else {
    return result;
  }
}

class ApiClient {
  final String _baseUrl = getBaseUrl();
  late final Map<String, String> _headers;

  ApiClient() {
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  signOut() {
    removeSharedPrefToken();
    _headers.remove('Authorization');
  }

  _storeToken(String token) {
    setSharedPrefToken(token);
    _headers['Authorization'] = 'Bearer $token';
  }

  Future<User> loginLocal() async {
    if (curEnv != AppEnvironment.local) {
      throw Exception('Function not supported for env $curEnv');
    }
    _storeToken(env('LOCAL_ACCESS_TOKEN'));
    User? res = await loggedInUser();
    if (res == null) {
      throw Exception(
          'Unable to find user with token ${env('LOCAL_ACCESS_TOKEN')}');
    }
    return res;
  }

  Future<User> loginGoogle(GoogleSignInAccount? account) async {
    if (account == null) {
      throw const HttpException('Unable to sign in google account');
    }
    GoogleSignInAuthentication auth = await account.authentication;

    Uri uri = Uri.parse('$_baseUrl/app/login/google');
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode(account.toJson(auth.accessToken)));
    if (res.statusCode != 200) {
      throw const HttpException('Unable to create or retrieve user');
    }
    if (auth.accessToken != null) {
      _storeToken(auth.accessToken!);
      if (kDebugMode) {
        print(auth.accessToken);
      }
    }
    return User.fromJson(json.decode(res.body));
  }

  Future<List<T>> _fetch<T>(String endpoint, FromJson<T> fromJson) async {
    Uri uri = Uri.parse('$_baseUrl/$endpoint');
    Response res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 4));
    if (res.statusCode != 200) {
      throw const HttpException('Unable to fetch');
    }
    var content = json.decode(utf8.decode(res.bodyBytes));
    if (content is Iterable) {
      return Future.wait(
          content.map((item) => _fromJsonHandler(fromJson, item)));
    } else {
      return [await _fromJsonHandler(fromJson, content)];
    }
  }

  Future<List<User>> groupMembers(String groupId) async =>
      _fetch<User>('groups/$groupId/members', User.fromJson);

  Future<List<Group>> groups() async =>
      _fetch<Group>('groups', (groupJson) async {
        String id = groupJson['id'];
        List<User> members = await groupMembers(id);
        return Group.fromJson(groupJson, members);
      });

  Future<List<User>> getUsers() async => _fetch<User>('users', User.fromJson);

  Future<List<User>> getUser(String userId) async =>
      _fetch<User>('users/$userId', User.fromJson);

  Future<List<Wish>> wishes() async => _fetch<Wish>('wishes', (wishJson) async {
        String id = wishJson['userId'];
        List<User> user = await getUser(id);
        return Wish.fromJson(wishJson, user.first);
      });

  Future<List<Wish>> wishesByLoggedOnUser() async {
    User? res = await loggedInUser();
    if (res == null) {
      return List.empty();
    } else {
      return _fetch<Wish>('users/${res.id}/wishes', (wishJson) async {
        String id = wishJson['userId'];
        List<User> user = await getUser(id);
        return Wish.fromJson(wishJson, user.first);
      });
    }
  }

  Future<String> getGroupInviteLink(String groupId) async {
    Uri uri = Uri.parse('$_baseUrl/groups/$groupId/invite');
    Response res = await http.post(uri, headers: _headers);
    if (res.statusCode > 201) {
      throw const HttpException('Unable to create invitation link');
    }
    return res.body;
  }

  Future<Wish> postWish(
      Occasion occasion,
      WishVisibility visibility,
      String? imageUrl,
      String description,
      String? groupId,
      String title) async {
    Uri uri = Uri.parse('$_baseUrl/wishes');

    Response res = await http.post(uri,
        headers: _headers,
        body: jsonEncode({
          'occasion': occasion.name,
          'status': Status.open.name,
          'visibility': visibility.name,
          'img': imageUrl,
          'description': description,
          'groupId': groupId,
          'title': title
        }));

    if (res.statusCode == 201) {
      // If the server returns a CREATED response
      return Wish.fromJson(
          jsonDecode(res.body), User('id', 'test', 'tester', 'test@test.com'));
    } else {
      // If the server returns an error response
      throw Exception('Failed to create wish: ${res.body}');
    }
  }

  Future<String> uploadImage(File selectedImage) async {
    Uri uri = Uri.parse('$_baseUrl/images');
    MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    request.files.add(
      await http.MultipartFile.fromPath('image', selectedImage.path,
          contentType: MediaType.parse(lookupMimeType(selectedImage.path)!),
          filename: basename(selectedImage.path)),
    );

    StreamedResponse streamedResponse = await request.send();
    Response res = await http.Response.fromStream(streamedResponse);
    if (res.statusCode == 201) {
      return res.body;
    } else {
      throw Exception('Failed to upload image: ${res.body}');
    }
  }

  Future<File?> getImage(String? imgId) async {
    if (imgId == null) {
      return null;
    } else {
      Uri uri = Uri.parse('$_baseUrl/images/$imgId');
      Response res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        String contentType = res.headers['content-type']!;
        String fileExtension = '.${contentType.split('/').last}';

        Directory tempDir = await getTemporaryDirectory();

        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$imgId$fileExtension';

        // Create the file in the temporary directory
        File file = File('${tempDir.path}/$fileName');

        // Write the bytes to the file
        await file.writeAsBytes(res.bodyBytes);

        return file;
      } else {
        throw Exception('Failed to load image: ${res.body}');
      }
    }
  }

  Future<User?> loginApple(AuthorizationCredentialAppleID credential) async {
    if (kDebugMode) {
      print(credential);
    }
    Uri uri = Uri.parse('$_baseUrl/app/login/apple');
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode(credential.toJson()));
    if (res.statusCode != 200) {
      throw const HttpException('Unable to create or retrieve user');
    }
    _storeToken(credential.authorizationCode);

    return User.fromJson(json.decode(res.body));
  }

  Future<List<Wish>> wishesForGroup(String groupId) async =>
      _fetch<Wish>('groups/$groupId/wishes', (wishJson) async {
        String id = wishJson['userId'];
        List<User> user = await getUser(id);
        return Wish.fromJson(wishJson, user.first);
      });

  Future<User?> loggedInUser() async =>
      (await _fetch<User>('me', User.fromJson)).firstOrNull;

  Future<User?> isStoredTokenValid() async {
    try {
      String? token = await getSharedPrefToken();
      if (token != null) {
        _storeToken(token);
      }
      var user = await loggedInUser();
      return user;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<int> loginEmail(String email) async {
    Uri uri = Uri.parse('$_baseUrl/app/login/email');
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode({'email': email}));
    return res.statusCode;
  }

  Future<int> loginOtp(String email, String otp) async {
    Uri uri = Uri.parse('$_baseUrl/app/login/email');
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode({'email': email, 'code': otp}));
    if (res.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(res.body);
      String? token = body['session']['token'];
      if (token != null) {
        _storeToken(token);
      }
    }
    return res.statusCode;
  }

  Future<User> updateUser({String? firstName, String? lastName}) async {
    Uri uri = Uri.parse('$_baseUrl/me');
    var res = await http.put(uri,
        headers: _headers,
        body: jsonEncode({'firstName': firstName, 'lastName': lastName}));
    return User.fromJson(json.decode(res.body));
  }
}

extension on AuthorizationCredentialAppleID {
  Map<String, dynamic> toJson() {
    return {
      'userIdentifier': userIdentifier,
      'givenName': givenName,
      'familyName': familyName,
      'email': email,
      'authorizationCode': authorizationCode,
      'identityToken': identityToken,
    };
  }
}
