import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

class FinancialPlatform {
  int platfromid;
  String name;
  String description;
  final Uint8List? iconimage; // financial platform icon
  final Color? iconColorExpense;

  FinancialPlatform({
    required this.platfromid,
    required this.name,
    required this.description,
    required this.iconimage,
    required this.iconColorExpense
  });

  factory FinancialPlatform.fromJson(Map<String, dynamic> json) {
    Uint8List? iconBytes;
    final rawIcon = json['iconimage'];
    if (rawIcon == null) {
      iconBytes = null;
    } else if (rawIcon is Map<String, dynamic>) {
      final data = rawIcon['data'];
      if (data is List) {
        iconBytes = Uint8List.fromList(List<int>.from(data));
      }
    } else if (rawIcon is List) {
      iconBytes = Uint8List.fromList(List<int>.from(rawIcon));
    } else if (rawIcon is String) {
      try {
        iconBytes = base64Decode(rawIcon);
      } catch (_) {
        iconBytes = null;
      }
    }

    return FinancialPlatform(
      platfromid: int.tryParse(json['platformid']?.toString().trim() ?? '0') ??
          0,
      name: json['name']?.toString() ?? '',
      // ✅ null-safe
      description: json['description']?.toString() ?? '',
      // ✅ null-safe
      iconimage: iconBytes,
      iconColorExpense: json['iconcolorexpense'] != null ? Color(
        // Safely parse color from int or string
        json['iconcolorexpense'] is int ? json['iconcolorexpense'] : int
            .tryParse(json['iconcolorexpense'].toString()) ?? 0,
      ) : Color(0xFF5A7BE7),
    );
  }
}