import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:mapnrank/common/ui.dart';
import 'package:permission_handler/permission_handler.dart';

class GetPermissions {
  /// Checking Location Permission
  static Future<bool> getCameraPermission() async {
    PermissionStatus permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      } else {
        Get.showSnackbar(Ui.warningSnackBar(message: "Camera permission is required"));
        return false;
      }
    }
    return false;
  }

  /// Checking External Storage Permission
  static Future<bool> getStoragePermission() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    PermissionStatus permissionStatus = await Permission.storage.status;
    print(permissionStatus.toString());
    print(androidDeviceInfo.version.sdkInt);
    // if(androidDeviceInfo.version.sdkInt < 33){
    //   if (permissionStatus.isGranted) {
    //     return true;
    //   } else if (permissionStatus.isDenied) {
    //     PermissionStatus status = await Permission.storage.status;
    //     if (status.isGranted) {
    //       return true;
    //     } else {
    //       Get.showSnackbar(Ui.warningSnackBar(message: "Gallery access is required"));
    //       return false;
    //     }
    // }
    //
    // }
    // else{
    //   return true;
    // }

    return true;
  }

  static Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted");
      GlobalService.notificationPermission = true;
    } else if (status.isDenied) {
      print("Notification permission denied");
      GlobalService.notificationPermission = false;
    } else if (status.isPermanentlyDenied) {
      GlobalService.notificationPermission = false;
      print("Notification permission permanently denied");
      // Optionally redirect the user to app settings.
    }
  }
}

