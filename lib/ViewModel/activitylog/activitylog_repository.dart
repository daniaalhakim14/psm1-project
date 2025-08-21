import 'package:fyp/Model/activitylog.dart';

import 'activitylog_callApi.dart';

class activitylog_repostiory {
  final activitylog_callApi _service = activitylog_callApi();

  Future<void> logActivity(ActivityLog activitylog, String token) async {
    final response = await _service.logActivity(activitylog.toMap(), token);
    if (response.statusCode != 201) {
      throw Exception('Failed to log activity to database: ${response.body}');
    }
  }
}
