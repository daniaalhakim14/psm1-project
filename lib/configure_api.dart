class AppConfig {
  // Base URL for API
  static String baseUrl = 'http://192.168.100.111:3000';

  // Function to update the base URL dynamically
  static void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
  }
}
