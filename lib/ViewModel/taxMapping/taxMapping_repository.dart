//The repository centralizes all data-fetching and data-processing
// logic in one place
import 'dart:convert';
import 'dart:async';
import '../../Model/taxMapping.dart';
import 'taxMapping_callApi.dart';

class TaxMappingRepository {
  final TaxMappingAPI _service = TaxMappingAPI();

  // Method with timeout handling for tax mapping
  Future<MappedTaxRelief?> processTaxMappingWithTimeout(
    String base64Pdf,
    int userId,
    String token, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Create the request payload
      final Map<String, dynamic> payload = {
        'base64Receipt': base64Pdf,
        'userId': userId,
      };

      // Apply timeout directly to the API call
      final response = await _service
          .mapTaxFromExpense(payload, token)
          .timeout(
            timeout,
            onTimeout: () {
              print(
                "Tax mapping API timed out after ${timeout.inSeconds} seconds",
              );
              throw TimeoutException('Tax mapping API timeout', timeout);
            },
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Tax mapping response: ${response.body}');

        // Handle AI response that might be wrapped in markdown code blocks
        if (jsonData['data'] != null && jsonData['data']['rawText'] != null) {
          String rawText = jsonData['data']['rawText'];

          // Clean up markdown code blocks if present
          if (rawText.contains('```json') && rawText.contains('```')) {
            // Extract JSON from markdown code blocks
            RegExp jsonRegex = RegExp(
              r'```json\s*\n?(.*?)\n?```',
              dotAll: true,
            );
            Match? match = jsonRegex.firstMatch(rawText);

            if (match != null) {
              try {
                String cleanJson = match.group(1)?.trim() ?? '';
                Map<String, dynamic> parsedData = jsonDecode(cleanJson);

                // Replace the rawText with parsed data
                jsonData['data'] = parsedData;
                jsonData['success'] = parsedData['eligible'] ?? false;

                print('Successfully parsed AI response from markdown');
              } catch (e) {
                print('Failed to parse cleaned JSON: $e');
                // Keep original data structure if parsing fails
              }
            }
          }
        }

        return MappedTaxRelief.fromJson(jsonData);
      } else {
        print('Tax mapping failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Tax mapping error: $e');
      return null;
    }
  }

  // Add a dispose method to clean up resources
  void dispose() {
    _service.dispose();
    print("TaxMappingRepository resources cleaned up.");
  }
}
