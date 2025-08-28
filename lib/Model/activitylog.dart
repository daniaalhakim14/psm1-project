class ActivityLog{
  final int userid;
  final int activitytypeid;
  final DateTime timestamp;

  ActivityLog({
    required this.userid,
    required this.activitytypeid,
    required this.timestamp
});

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      userid: int.parse(json['userid'].toString()),
      activitytypeid: int.parse(json['activitytypeid'].toString()),
      timestamp:  DateTime.parse(json['timestamp'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'activitytypeid': activitytypeid,
      'timestamp':  timestamp.toUtc().toIso8601String(),
    };
  }
}