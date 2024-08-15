import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gaveliste_app/auth/google_login.dart';
import 'package:gaveliste_app/main.dart';
import 'package:gaveliste_app/util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple_platform_interface/authorization_credential.dart';

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

  loginLocal() async {
    if (curEnv != AppEnvironment.local) {
      throw Exception("Function not supported for env $curEnv");
    }
    _headers['Authorization'] = "Bearer ${env('LOCAL_ACCESS_TOKEN')}";
    List<User> res = await _fetch<User>("me", User.fromJson);
    if (res.isEmpty) {
      throw Exception(
          "Unable to find user with token ${env('LOCAL_ACCESS_TOKEN')}");
    }
  }

  Future<Response> loginGoogle(GoogleSignInAccount? account) async {
    if (account == null) {
      throw const HttpException("Unable to sign in google account");
    }
    GoogleSignInAuthentication auth = await account.authentication;

    Uri uri = Uri.parse("$_baseUrl/appLogin/google");
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode(account.toJson(auth.accessToken)));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to create or retrieve user");
    }
    if (auth.accessToken != null) {
      _headers['Authorization'] = "Bearer ${auth.accessToken!}";
      if (kDebugMode) {
        print(auth.accessToken);
      }
    }
    return res;
  }

  Future<List<T>> _fetch<T>(String endpoint, FromJson<T> fromJson) async {
    Uri uri = Uri.parse("$_baseUrl/$endpoint");
    Response res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 4));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to fetch");
    }
    var content = json.decode(res.body);
    if (content is Iterable) {
      return Future.wait(
          content.map((item) => _fromJsonHandler(fromJson, item)));
    } else {
      return [await _fromJsonHandler(fromJson, content)];
    }
  }

  Future<List<User>> groupMembers(String groupId) async =>
      _fetch<User>("groups/$groupId/members", User.fromJson);

  Future<List<Group>> groups() async =>
      _fetch<Group>("groups", (groupJson) async {
        String id = groupJson['id'];
        List<User> members = await groupMembers(id);
        return Group.fromJson(groupJson, members);
      });

  Future<List<User>> getUser(String userId) async =>
      _fetch<User>("users/$userId", User.fromJson);

  Future<List<Wish>> wishes() async => _fetch<Wish>("wishes", (wishJson) async {
        String id = wishJson['userId'];
        List<User> user = await getUser(id);
        return Wish.fromJson(wishJson, user.first);
      });

  Future<String> getGroupInviteLink(String groupId) async {
    Uri uri = Uri.parse("$_baseUrl/groups/$groupId/invite");
    Response res = await http.post(uri, headers: _headers);
    if (res.statusCode > 201) {
      throw const HttpException("Unable to create invitation link");
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
    Uri uri = Uri.parse("$_baseUrl/wishes");

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
          jsonDecode(res.body), User("id", "test", "tester", "test@test.com"));
    } else {
      // If the server returns an error response
      throw Exception('Failed to create wish: ${res.body}');
    }
  }

  Future<String> uploadImage(File selectedImage) async {
    Uri uri = Uri.parse("$_baseUrl/images");
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
      Uri uri = Uri.parse("$_baseUrl/images/$imgId");
      Response res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        String contentType = res.headers['content-type']!;
        String fileExtension = ".${contentType.split("/").last}";

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

  Future<Response> loginApple(AuthorizationCredentialAppleID credential) async {
    Uri uri = Uri.parse("$_baseUrl/appLogin/apple");
    Response res =
        await http.post(uri, headers: _headers, body: jsonEncode(credential));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to create or retrieve user");
    }
    _headers['Authorization'] = "Bearer ${credential.identityToken}";
    if (kDebugMode) {
      print(credential);
    }

    return res;
  }
}
