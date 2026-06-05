enum AppEnvironment {
  mock,
  local,
  androidEmulator,
  realDevice,
  production,
}

class AppConfig {
  AppConfig._();

  static const AppEnvironment environment = AppEnvironment.mock;

  static const String localApiBaseUrl = 'http://localhost:8080/api/v1';

  static const String androidEmulatorApiBaseUrl = 'http://10.0.2.2:8080/api/v1';

  // Change this IP based on your Mac local network IP when testing on real device.
  static const String realDeviceApiBaseUrl = 'http://192.168.0.105:8080/api/v1';

  static const String productionApiBaseUrl = 'https://api.familyfund.com/api/v1';

  static bool get useMockData => environment == AppEnvironment.mock;

  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.mock:
        return '';

      case AppEnvironment.local:
        return localApiBaseUrl;

      case AppEnvironment.androidEmulator:
        return androidEmulatorApiBaseUrl;

      case AppEnvironment.realDevice:
        return realDeviceApiBaseUrl;

      case AppEnvironment.production:
        return productionApiBaseUrl;
    }
  }

  static const int apiTimeoutSeconds = 30;

  static const bool enableGoogleLogin = true;
  static const bool enableBanglaLanguage = true;
  static const bool enableBiometricLogin = false;
  static const bool enableDebugLogs = true;
}