
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../common/ui.dart';
import '../../../models/user_model.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




class NotificationController extends GetxController {

  final Rx<UserModel> currentUser = Get.find<AuthService>().user;
  var notifications = [].obs;
  var createdNotifications = [].obs;
  var receivedNotifications = [].obs;
  var notificationList = [];
  RxBool loadingNotifications = true.obs;
  RxBool createNotification = false.obs;
  late NotificationRepository notificationRepository;
  late ZoneRepository zoneRepository ;
  RxBool isMyCreatedNotification = true.obs;
  var loadingRegions = true.obs;
  var regions = [].obs;
  var regionSelected = false.obs;
  var regionSelectedIndex = 0.obs;
  var listRegions = [].obs;
  var regionsSet ={};
  var regionSelectedValue = [].obs;
  var imageFiles = [].obs;

  var loadingDivisions = true.obs;
  var divisions = [].obs;
  var divisionSelected = false.obs;
  var divisionSelectedValue = [].obs;
  var divisionSelectedIndex = 0.obs;
  var listDivisions = [].obs;
  var divisionsSet ={};

  var loadingSubdivisions = true.obs;
  var subdivisions = [].obs;
  var subdivisionSelected = false.obs;
  var subdivisionSelectedValue = [].obs;
  var subdivisionSelectedIndex = 0.obs;
  var listSubdivisions = [].obs;
  var subdivisionsSet ={};

  var chooseARegion = false.obs;
  var chooseADivision = false.obs;
  var chooseASubDivision = false.obs;

  late NotificationModel notification;



  NotificationController() {
    notificationRepository = NotificationRepository();
  }

  @override
  void onInit() async {
    zoneRepository = ZoneRepository();
    notificationRepository = NotificationRepository();
    notification = NotificationModel();
    notifications.value = await getNotifications();
    super.onInit();
  }

  @override
  void dispose() {

    super.dispose();
  }

  Future refreshNotification() async {
    notificationList = await getNotifications();
    notifications.value = notificationList;


  }

  classifyNotifications(var notificationList){
    createdNotifications.clear();
    receivedNotifications.clear();
    for(var notification in notificationList){
      if(notification.userModel.userId == Get.find<AuthService>().user.value.userId ){
        createdNotifications.add(notification);
      }
      else{
        receivedNotifications.add(notification);
      }
    }
  }

  Future getNotifications() async {
    loadingNotifications.value = true;
    notificationList.clear();
    notifications.clear();
    try{
      var list = await notificationRepository.getUserNotifications();
      print(list);
      for( var i = 0; i< list.length; i++){
        UserModel user = UserModel(
            userId: list[i]['user']['id'],
            lastName:list[i]['user']['last_name'],
            firstName: list[i]['user']['first_name'],
            avatarUrl: list[i]['user']['avatar']
        );
        var notification = NotificationModel(
          notificationId: list[i]['id'],
            content: Get.find<AuthService>().user.value.language == 'en'?list[i]['content_en']:list[i]['content_fr'],
          title: Get.find<AuthService>().user.value.language == 'en'?list[i]['titre_en']:list[i]['titre_fr'],
          userModel: user,
          date: list[i]['created_at'],
          bannerUrl: list[i]['image'].toString(),
          zoneName: list[i]['zone']['name']

        );
        //notificationList.clear();
        notificationList.add(notification);
      }
      if(currentUser.value.type?.toUpperCase() == "COUNCIL"){
        await classifyNotifications(notificationList);
      }
      loadingNotifications.value = false;
      return notificationList;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      loadingNotifications.value = false;


    }

  }

  Future  pickImage(ImageSource source) async {

    ImagePicker imagePicker = ImagePicker();

    if(source.toString() == ImageSource.camera.toString())
    {
      var compressedImage;
      XFile? pickedFile = await imagePicker.pickImage(source: source, imageQuality: 80);
      File imageFile = File(pickedFile!.path);
      if(imageFile.lengthSync()>pow(1024, 2)){
        // coverage:ignore-start
        final tempDir = await getTemporaryDirectory();
        final path = tempDir.path;
        int rand = Math.Random().nextInt(10000);
        Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
        compressedImage = File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));
        // coverage:ignore-end


      }
      else{

        compressedImage = File(pickedFile.path);

      }

      imageFiles.add(compressedImage) ;
      notification.imageNotificationBanner = imageFiles;

    }
    else{
      var compressedImage;
      var i =0;
      var galleryFiles = await imagePicker.pickMultiImage();

      while(i<galleryFiles.length){
        File imageFile = File(galleryFiles[i].path);
        if(imageFile.lengthSync()>pow(1024, 2)){
          // coverage:ignore-start
          final tempDir = await getTemporaryDirectory();
          final path = tempDir.path;
          int rand = Math.Random().nextInt(10000);
          Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
          compressedImage =  File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));
          // coverage:ignore-end


        }
        else{

          compressedImage = File(galleryFiles[i].path);

        }


        imageFiles.add(compressedImage) ;
        notification.imageNotificationBanner = imageFiles;


        i++;
      }
    }
  }

  getAllRegions() async{
    return zoneRepository.getAllRegions(2, 1);
  }

  void filterSearchRegions(String query) {
    List dummySearchList = [];
    dummySearchList = listRegions;
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['name']
          .toString().toLowerCase().contains(query.toLowerCase())).toList();
      regions.value = dummyListData;
      return;
    } else {
      regions.value = listRegions;
    }
  }

  getAllDivisions(int index) async{
    print(zoneRepository.getAllDivisions(3, regions[index]['id']));
    return zoneRepository.getAllDivisions(3, regions[index]['id']);

  }

  void filterSearchDivisions(String query) {
    List dummySearchList = [];
    dummySearchList = listDivisions;
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['name']
          .toString().toLowerCase().contains(query.toLowerCase())).toList();
      divisions.value = dummyListData;
      return;
    } else {
      divisions.value = listDivisions;
    }
  }

  getAllSubdivisions(int index) async{
    return zoneRepository.getAllSubdivisions(4, divisions[index]['id']);

  }

  void filterSearchSubdivisions(String query) {
    List dummySearchList = [];
    dummySearchList = listSubdivisions;
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['name']
          .toString().toLowerCase().contains(query.toLowerCase())).toList();
      subdivisions.value = dummyListData;
      return;
    } else {
      subdivisions.value = listSubdivisions;
    }
  }

  createNotifications(NotificationModel notification)async{
    try{
      createNotification.value = true;
     var result = await notificationRepository.createNotification(notification);
     print(result);
      await getNotifications();
      createNotification.value = false;

      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).notification_created_successfully ));
      Navigator.pop(Get.context!);

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        createNotification.value = false;
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      createNotification.value = false;
    }

  }

  deleteSpecificNotification(int id) async {
    try{
      var result = await notificationRepository.deleteSpecificNotification(id);
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Notification deleted successfully"));
      }
      return result;
    }
    catch(e){
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }

  }

}


