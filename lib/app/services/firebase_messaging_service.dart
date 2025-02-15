
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../color_constants.dart';
import '../../common/ui.dart';
import '../../main.dart';
import '../modules/community/controllers/community_controller.dart';
import '../modules/notifications/controllers/notification_controller.dart';
import '../modules/root/controllers/root_controller.dart';
import '../routes/app_routes.dart';
import 'auth_service.dart';

class FireBaseMessagingService extends GetxService {
  Future<FireBaseMessagingService> init() async {
    //`FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);
    await requestPermission();
    await setDeviceToken();
    await fcmOnLaunchListeners();
    await fcmOnResumeListeners();
    await fcmOnMessageListeners();
    return this;
  }
   requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("User permission granted");
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("user granted a provisional permission ");
      }
    } else {
      if (kDebugMode) {
        print("user did not granted permission");
      }

      showDialog(
          context: Get.context!,
          builder: (_){
            return AlertDialog(
              content: Container(
                height: 170,
                padding: EdgeInsets.all(10),
                child: Text('Allow your device to receive notifications from Hubkilo in the device settings', style: Get.textTheme.displayMedium),
              ),
            );
          });
    }
  }

  Future fcmOnMessageListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      if (Get.isRegistered<RootController>()) {
        Get.find<RootController>().getNotificationsCount();
      }

        _massNotification(message);
       var count = 0;
      NotificationController _notificationController = new NotificationController();
      var list = await _notificationController.getNotifications();
      for(int i =0; i<list.length; i++ ){
            count = count +1;
      }
      Get.find<RootController>().notificationsCount.value = count ;
    });
  }

  Future fcmOnLaunchListeners() async {
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _notificationsBackground(message);
    }
  }

  Future fcmOnResumeListeners() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      var count = 0;
      NotificationController _notificationController = new NotificationController();
      var list = await _notificationController.getNotifications();
      for(int i =0; i<list.length; i++ ){
            count = count +1;
      }
      Get.find<RootController>().notificationsCount.value = count ;

      _notificationsBackground(message);
    });
  }

  void _notificationsBackground(RemoteMessage message) {
    if (message.data['id'] == "App\\Notifications\\NewMessage") {
      _newMessageNotificationBackground(message);
    } else {
      _newBookingNotificationBackground(message);
    }
  }

  void _newBookingNotificationBackground(message) {
    if (Get.isRegistered<RootController>()) {
      //Get.toNamed(Routes.BOOKING, arguments: new Booking(id: message.data['bookingId']));
    }
  }

  void _newMessageNotificationBackground(RemoteMessage message) {
    if (message.data['messageId'] != null) {
      //Get.toNamed(Routes.CHAT, arguments: new Message([], id: message.data['messageId']));
    }
  }

  Future<void> setDeviceToken() async {
    //Get.find<AuthService>().user.value.deviceToken =
    getToken();
  }

  getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {

      var mtoken = token;
      Get.find<AuthService>().user.value.firebaseToken = token;
      if (kDebugMode) {
        print("my token is $mtoken");
      }
      //Domain.deviceToken = token;
    });

  }

  void _massNotification(RemoteMessage message) {
    if (Get.currentRoute == Routes.ROOT) {
      Get.find<CommunityController>().refreshCommunity();
    }
    RemoteNotification? notification = message.notification;
    Get.showSnackbar(Ui.notificationSnackBar(
      title: notification!.title!,
      message: notification!.body!,
      mainButton: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        width: 30,
        height: 30,
      ),
      onTap: (getBar) async {
        if (message.data['id'] != null) {
          //Get.back();
          //Get.toNamed(Routes.N, arguments: new Booking(id: message.data['bookingId']));
        }
      },
    ));
  }

}