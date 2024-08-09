import '../api_client.dart';

void handleLocalSignIn(
    ApiClient client, void Function(bool? signedIn) signedInCallback) {
  client.loginLocal();
  signedInCallback(true);
}
