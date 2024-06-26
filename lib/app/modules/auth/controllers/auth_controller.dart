import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapnrank/app/modules/root/controllers/root_controller.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../color_constants.dart';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

import '../../../../common/ui.dart';
import '../../../models/user_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../chat_room/controllers/chat_room_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';


class AuthController extends GetxController {

  final Rx<User> currentUser = Get.find<AuthService>().user;
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<FormState> registerFormKey;
  final hidePassword = true.obs;
  RxBool loading = false.obs;
  RxBool registerNext = false.obs;
  RxBool registerNextStep1 = false.obs;
  final _picker = ImagePicker();
  late File profileImage = File('assets/images/loading.gif') ;
  final loadProfileImage = false.obs;
  var birthDate = "--/--/--".obs;
  var birthDateDisplay = "--/--/--".obs;

  var loadingRegions = true.obs;
  var regions = [].obs;
  var regionSelected = false.obs;
  var regionSelectedIndex = 0.obs;
  var listRegions = [].obs;
  var regionsSet ={};
  var regionSelectedValue = [].obs;

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

  var loadingSectors = true.obs;
  var sectors = [].obs;
  var sectorsSelected = [].obs;
  var selectedIndex = 0.obs;
  var listSectors = [].obs;
  var sectorsSet ={};

  var confirmPassword='';
  RxBool isConfidentialityChecked = false.obs;
  late UserRepository userRepository ;
  late ZoneRepository zoneRepository ;
  late SectorRepository sectorRepository ;

  var selectedGender = 'Select  your gender'.obs;

  var genderList = [
    'Select  your gender',
    'Male',
    'Female',
    'Other'
  ].obs;


  AuthController(){
    Get.lazyPut(()=>RootController());
    Get.lazyPut<AuthService>(
          () => AuthService(),
    );

    Get.lazyPut<LaravelApiClient>(
          () => LaravelApiClient(),
    );
    Get.lazyPut<DashboardController>(
          () => DashboardController(),
    );
    Get.lazyPut<CommunityController>(
          () => CommunityController(),
    );
    Get.lazyPut<ChatRoomController>(
          () => ChatRoomController(),
    );
    Get.lazyPut<ProfileController>(
          () => ProfileController(),
    );

  }



  @override
  void onInit() async {
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();


    var box = GetStorage();

    var boxRegions = box.read("allRegions");

    if(boxRegions == null){
      regionsSet = await getAllRegions();
      listRegions.value = regionsSet['data'];
      loadingRegions.value = !regionsSet['status'];
      regions.value = listRegions;

      box.write("allRegions", regionsSet);

    }
    else{
      listRegions.value = boxRegions['data'];
      loadingRegions.value = !boxRegions['status'];
      regions.value = listRegions;


    }

    var boxSectors = box.read("allSectors");

    if(boxSectors == null){
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: Text('Loading Sectors...'),
        duration: Duration(seconds: 3),
      ));

      sectorsSet = await getAllSectors();
      listSectors.value = sectorsSet['data'];
      loadingSectors.value = !sectorsSet['status'];
      sectors.value = listSectors;

      box.write("allSectors", sectorsSet);

    }
    else{
      listSectors.value = boxSectors['data'];
      loadingSectors.value = !boxSectors['status'];
      sectors.value = listSectors;


    }


    super.onInit();
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


  void filterSearchSectors(String query) {
    List dummySearchList = [];
    dummySearchList = listSectors;
    if(query.isNotEmpty) {
      List dummyListData = [];
      dummyListData = dummySearchList.where((element) => element['name']
          .toString().toLowerCase().contains(query.toLowerCase())).toList();
      sectors.value = dummyListData;
      return;
    } else {
      sectors.value = listSectors;
    }
  }

  birthDatePicker() async {
    DateTime? pickedDate = await showRoundedDatePicker(

      context: Get.context!,
      theme: ThemeData.light().copyWith(
          primaryColor: buttonColor
      ),
      height: Get.height/2,
      initialDate: DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(1950),
      lastDate: DateTime(2040),
      styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleYearButton: const TextStyle(
            fontSize: 52,
            color: Colors.white,
          )
      ),
      borderRadius: 16,
      //selectableDayPredicate: disableDate
    );
    if (pickedDate != null ) {
      //birthDate.value = DateFormat('dd/MM/yy').format(pickedDate);
      birthDateDisplay.value = DateFormat('dd-MM-yyyy').format(pickedDate);
      birthDate.value =DateFormat('yyyy-MM-dd').format(pickedDate);
      currentUser.value.birthdate = birthDate.value;
    }
  }
  selectCameraOrGalleryProfileImage(){
    showDialog(
        context: Get.context!,
        builder: (_){
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
                height: 170,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      onTap: ()async{
                        await profileImagePicker('camera');
                        //Navigator.pop(Get.context);


                      },
                      leading: const Icon(FontAwesomeIcons.camera),
                      title: Text('Take a picture', style: Get.textTheme.headline1?.merge(const TextStyle(fontSize: 15))),
                    ),
                    ListTile(
                      onTap: ()async{
                        await profileImagePicker('gallery');
                        //Navigator.pop(Get.context);

                      },
                      leading: const Icon(FontAwesomeIcons.image),
                      title: Text('Upload Image', style: Get.textTheme.headline1?.merge(const TextStyle(fontSize: 15))),
                    )
                  ],
                )
            ),
          );
        });
  }
  profileImagePicker(String source) async {
    if(source=='camera'){
      final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        var imageFile = File(pickedImage.path);
        if(imageFile.lengthSync()>pow(1024, 2)){
          final tempDir = await getTemporaryDirectory();
          final path = tempDir.path;
          int rand = Math.Random().nextInt(10000);
          Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
          var compressedImage =  File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));
          print('Lenght'+compressedImage.lengthSync().toString());
          profileImage = compressedImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        else{
          profileImage = File(pickedImage.path);
          loadProfileImage.value = !loadProfileImage.value;

        }
        Navigator.of(Get.context!).pop();
        //Get.showSnackbar(Ui.SuccessSnackBar(message: "Picture saved successfully".tr));
        //loadIdentityFile.value = !loadIdentityFile.value;//Navigator.of(Get.context).pop();
      }

    }
    else{
      final XFile? pickedImage =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        var imageFile = File(pickedImage.path);
        if(imageFile.lengthSync()>pow(1024, 2)){
          final tempDir = await getTemporaryDirectory();
          final path = tempDir.path;
          int rand = new Math.Random().nextInt(10000);
          Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
          var compressedImage =  File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));
          print('Lenght'+compressedImage.lengthSync().toString());
          profileImage = compressedImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        else{
          print(pickedImage);
          profileImage = File(pickedImage.path);
          loadProfileImage.value = !loadProfileImage.value;

        }
        Navigator.of(Get.context!).pop();
      }

    }
  }

  void register() async {
    try {
      currentUser.value = await userRepository.register(currentUser.value);
      await Get.find<RootController>().changePage(0);
      Get.showSnackbar(Ui.SuccessSnackBar(message: 'Your account was created successfully' ));
    }
    catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      loading.value = false;
    }

  }

  login() async {
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      loading.value = true;
      try {
        currentUser.value = await userRepository.login(currentUser.value);
        if (kDebugMode) {
          print('Christellle');
          print(currentUser.value);
        }
        if (kDebugMode) {
          print(Get.find<AuthService>().user.value.authToken);
        }
        await Get.find<RootController>().changePage(0);
        Get.showSnackbar(Ui.SuccessSnackBar(message: 'User logged in successfully' ));
      }
      catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
      }
    }



  }


  getAllSectors() async{
    return sectorRepository.getAllSectors();
  }



}