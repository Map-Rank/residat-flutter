import 'package:get/get.dart';
import 'package:mapnrank/app/models/feedback_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import '../models/notification_model.dart';
import '../providers/laravel_provider.dart';

class NotificationRepository {
  late LaravelApiClient _laravelApiClient;
  Future getUserNotifications() {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getUserNotifications();
  }

  Future getSpecificNotification<int>(var id) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getSpecificNotification(id);
  }

  Future deleteSpecificNotification<int>(var id) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.deleteSpecificNotification(id);
  }

  Future createNotification(NotificationModel notification) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.createNotification(notification);

  }


}
