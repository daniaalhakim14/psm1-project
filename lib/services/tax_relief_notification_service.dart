import 'package:flutter/material.dart';
import '../Model/taxMapping.dart';

class TaxReliefNotificationService {
  /// Shows a tax relief notification when an expense is eligible
  static void showTaxReliefNotification(
    BuildContext context,
    MappedTaxRelief taxResult,
  ) {
    if (!context.mounted) return;

    // Get additional information from tax result
    final categoryName =
        taxResult.data?.matches?.isNotEmpty == true
            ? taxResult.data!.matches!.first.categoryName ?? 'tax relief'
            : 'tax relief';
    final reliefAmount = taxResult.data?.totalReliefAmount;
    final itemName =
        taxResult.data?.matches?.isNotEmpty == true
            ? taxResult.data!.matches!.first.itemName
            : null;

    // Show a snackbar notification first
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.account_balance, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '🎉 Great! This expense is eligible for tax relief!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Show a detailed dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.celebration, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tax Relief Eligible!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Congratulations! This expense qualifies for tax relief.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              if (categoryName != 'tax relief') ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: $categoryName',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      if (itemName != null)
                        Text(
                          'Item: $itemName',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                      if (reliefAmount != null)
                        Text(
                          'Relief Amount: RM $reliefAmount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const Text(
                'You can claim this expense to reduce your taxable income. Make sure to keep your receipt for tax filing purposes.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text(
                'Got it!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a simple tax relief notification with custom message
  static void showSimpleTaxReliefNotification(
    BuildContext context, {
    String message = 'This expense is eligible for tax relief!',
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.account_balance, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
