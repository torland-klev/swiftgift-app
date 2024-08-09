import 'package:flutter_dotenv/flutter_dotenv.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String env(String key) {
  return dotenv.env[key] ?? (throw Exception("Env variable $key missing"));
}

enum AppEnvironment { debug, local, production }

AppEnvironment appEnv() {
  return AppEnvironment.values.byName(dotenv.env['APP_ENV']?.toLowerCase() ??
      (throw FormatException(
          "Env variable APP_ENV not set to a valid value. One of ${AppEnvironment.values} expected.")));
}

String getBaseUrl() {
  switch (appEnv()) {
    case AppEnvironment.production:
      return env('API_URL');
    case AppEnvironment.debug:
      return env('DEBUG_API_URL');
    case AppEnvironment.local:
      return env('LOCAL_API_URL');
  }
}
