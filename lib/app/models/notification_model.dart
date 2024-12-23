
import 'package:mapnrank/app/models/user_model.dart';

import 'parents/model.dart';

class NotificationModel extends Model {
  int? notificationId;
  String? content;
  String? title;
  String? date;
  UserModel? userModel;
  String? zoneId;
  String? zoneName;
  String? bannerUrl;
  List? imageNotificationBanner;


  NotificationModel({this.userModel, this.title, this.notificationId, this.content, this.date, this.zoneId, this.imageNotificationBanner, this.zoneName, this.bannerUrl});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    return data;
  }




}
