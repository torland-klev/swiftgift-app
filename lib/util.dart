import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
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

Future<String?> getFromPref(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

String _bearerTokenKey = "BEARER_TOKEN";

Future<String?> getSharedPrefToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(_bearerTokenKey);
}

Future<bool> setSharedPrefToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(_bearerTokenKey, token);
}

Future<bool> removeSharedPrefToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(_bearerTokenKey);
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

ThemeData themeData = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.light,
    primary: Colors.blueAccent,
    secondary: Colors.amberAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  useMaterial3: true,
  textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(
          color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 20)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blueAccent,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blueAccent,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
);
