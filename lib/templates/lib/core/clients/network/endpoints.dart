class RemoteEndpoints {
  // Remove baseUrl field — compute it on-demand
  // static String get baseUrl => Locator.instance<AppEnvironment>().baseUrl;
  static String get baseUrl => "http://192.168.1.26:8000/";

  // Private constructor (singleton pattern not needed anymore)
  RemoteEndpoints._();

  // api version
  static String version = 'api/v1';
  static String baseEndpoint = '$baseUrl/$version';

  // Endpoints (now safe to use anywhere!)
  static const String onboarding = '/onboarding';
  static String login = '/auth/login';
  static String products = '/products';

  // Dynamic endpoints
  static String productDetails(String id) => '/products/$id';
}
