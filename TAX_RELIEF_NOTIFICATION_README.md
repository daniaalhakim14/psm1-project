# Tax Relief Notification Implementation

This implementation adds automatic notifications when an expense is detected as eligible for tax relief.

## How it works

1. **Automatic Detection**: When a user adds an expense with a receipt, the app automatically performs tax mapping using the receipt's content.

2. **Tax Relief Check**: The system checks if the expense qualifies for any tax relief categories based on Malaysian tax regulations.

3. **Smart Notifications**: If eligible, the user receives both:
   - A snackbar notification for immediate feedback
   - A detailed dialog showing specific tax relief information

## Implementation Details

### Files Modified
- `lib/View/expenseInput.dart` - Added tax relief notification when adding expenses
- `lib/services/tax_relief_notification_service.dart` - Reusable notification service

### Service Usage

```dart
// Import the service
import 'package:fyp/services/tax_relief_notification_service.dart';

// Use after tax mapping
if (taxMappingResult != null && taxMappingResult.isEligible) {
  TaxReliefNotificationService.showTaxReliefNotification(
    context,
    taxMappingResult,
  );
}

// Or use simple notification
TaxReliefNotificationService.showSimpleTaxReliefNotification(
  context,
  message: 'Custom tax relief message',
);
```

### Features

1. **Detailed Information Display**:
   - Tax relief category name
   - Specific item name
   - Relief amount (if available)
   - General guidance message

2. **User-Friendly UI**:
   - Green color scheme for positive feedback
   - Clear icons and formatting
   - Professional dialog design

3. **Flexible Usage**:
   - Can be used from any widget
   - Customizable messages
   - Reusable across the app

## Console Output

When tax mapping is successful, you'll see these logs:
```
I/flutter: Tax mapping successful - eligible for relief
I/flutter: Tax mapping completed successfully
I/flutter: Tax mapping result: Instance of 'MappedTaxRelief'
```

The notification will then automatically appear to inform the user about their tax relief eligibility.

## Future Enhancements

- Could be extended to show historical tax relief eligible expenses
- Integration with tax reporting features
- Reminder notifications for tax filing season
- Detailed tax relief calculations
