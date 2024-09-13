import '../api_client.dart';
import '../data/user.dart';

Future<void> handleLocalSignIn(
    ApiClient client, void Function(User? signedIn) signedInCallback) async {
  signedInCallback(await client.loginLocal());
}
