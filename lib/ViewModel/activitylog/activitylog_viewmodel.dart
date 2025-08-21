import 'package:flutter/cupertino.dart';
import '../../Model/activitylog.dart';
import 'activitylog_repository.dart';

class activitylog_viewModel extends ChangeNotifier{
  final repository = activitylog_repostiory();

  Future<void> logActivity(ActivityLog activitylog, String token) async{
    try{
      await repository.logActivity(activitylog, token);
    }catch(e){
      print('Failed to log activity to database: $e');
    }
  }
}
