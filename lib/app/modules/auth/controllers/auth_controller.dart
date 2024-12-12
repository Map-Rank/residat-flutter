import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/root/controllers/root_controller.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../color_constants.dart';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

import '../../../../common/ui.dart';
import '../../../models/user_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../community/controllers/community_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../notifications/controllers/notification_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AuthController extends GetxController {

  Rx<UserModel> currentUser = Get.find<AuthService>().user;
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<FormState> registerFormKey;
  late GlobalKey<FormState> institutionalUserFormKey;
  final hidePassword = true.obs;
  RxBool loading = false.obs;
  RxBool registerNext = false.obs;
  RxBool institutionalUserNext = false.obs;
  RxBool registerNextStep1 = false.obs;
  var picker = ImagePicker();
  late File profileImage = File('assets/images/loading.gif') ;
  final loadProfileImage = false.obs;
  var birthDate = "--/--/--".obs;
  TextEditingController birthDateDisplay = TextEditingController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController institutionNameController = TextEditingController();
  TextEditingController institutionEmailController = TextEditingController();
  TextEditingController institutionPhoneController = TextEditingController();
  TextEditingController institutionDescriptionController = TextEditingController();
  var emailFocus = false;
  var phoneFocus = false;






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
  var loginOrRegister = true.obs;
  var sectors = [].obs;
  var sectorsSelected = [].obs;
  var selectedIndex = 0.obs;
  var listSectors = [].obs;
  var sectorsSet ={};

  var chooseSector = false.obs;
  var chooseRegion = false.obs;
  var chooseDivision = false.obs;
  var chooseSubdivision = false.obs;
  var loginWithPhoneNumber = false.obs;
  var phoneNumber;


  var confirmPassword='';
  RxBool isConfidentialityChecked = false.obs;
  late UserRepository userRepository ;
  late ZoneRepository zoneRepository ;
  late SectorRepository sectorRepository ;

  var selectedGender = ''.obs;

  var selectedCoverageZone = ''.obs;

  RxList<String> genderList = RxList();

  RxList<String> institutionZoneCoverageList = RxList();

  var selectedLanguage = ''.obs;

  RxList<String> languageList = RxList();

  var box = GetStorage();

  RxDouble progress = 0.0.obs;
  Timer? _timer;
  Duration duration = Duration(seconds: 10); // Total duration of the progress



  AuthController(){

    Get.lazyPut(()=>RootController());
    Get.lazyPut(() => AuthService());

    Get.lazyPut(() => LaravelApiClient(dio: Dio()));
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => CommunityController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => EventsController());

  }



  @override
  void onInit() async {
    progress = 0.0.obs;
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();
    loginFormKey = GlobalKey<FormState>();
// coverage:ignore-start
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    selectedGender = AppLocalizations.of(Get.context!).select_gender.obs;
    selectedCoverageZone = AppLocalizations.of(Get.context!).national.obs;
    genderList = [
      AppLocalizations.of(Get.context!).select_gender,
      AppLocalizations.of(Get.context!).male,
      AppLocalizations.of(Get.context!).female,
      AppLocalizations.of(Get.context!).other
    ].obs;
    languageList = [
      AppLocalizations.of(Get.context!).select_language,
      AppLocalizations.of(Get.context!).en,
      AppLocalizations.of(Get.context!).fr,

    ].obs;
    institutionZoneCoverageList = [
      AppLocalizations.of(Get.context!).national,
      AppLocalizations.of(Get.context!).regional,
      AppLocalizations.of(Get.context!).divisional,
      AppLocalizations.of(Get.context!).sub_divisional,


    ].obs;// cover
    selectedLanguage = AppLocalizations.of(Get.context!).select_language.obs;
    birthDateDisplay.text = "--/--/--";

    if(box.read('language')==null){
        await showDialog(context: Get.context!,
          barrierDismissible: false,
          builder: (context) =>
              Dialog(
                insetPadding: EdgeInsets.symmetric(
                    vertical: Get.height /3.2, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(AppLocalizations
                        .of(context)
                        .choose_language, style: Get.textTheme.labelMedium
                    ).marginOnly(left: 10),
                    Stack(
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius
                                      .circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Get.theme.focusColor.withOpacity(
                                            0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 5)),
                                  ],
                                  border: Border.all(color: Get.theme.focusColor
                                      .withOpacity(0.5))
                              ),
                              child: DropdownButtonFormField(
                                dropdownColor: Colors.white,
                                decoration: const InputDecoration.collapsed(
                                  hintText: '',

                                ),

                                isExpanded: true,
                                alignment: Alignment.bottomCenter,

                                style: const TextStyle(color: labelColor),
                                value: selectedLanguage.value,
                                // Down Arrow Icon
                                icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black,),

                                // Array list of items
                                items: languageList.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items,
                                      style: Get.textTheme.headlineMedium,
                                      textAlign: TextAlign.center,),
                                  );
                                }).toList(),
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (String? newValue) {
                                  selectedLanguage.value = newValue!;
                                  if (selectedLanguage.value == "French" ||
                                      selectedLanguage.value == "Français") {
                                    box.write("language", 'fr');
                                    Get.updateLocale(const Locale('fr'));
                                    currentUser.value.language = 'fr';
                                  }
                                  else if (selectedLanguage.value == "English" ||
                                      selectedLanguage.value == "Anglais") {
                                    box.write("language", 'en');
                                    Get.updateLocale(const Locale('en'));
                                    currentUser.value.language = 'en';
                                  }
                                },)
                                  .marginOnly(left: 50, right: 20,)
                                  .paddingOnly(top: 10, bottom: 10)
                          ).paddingOnly(top: 10, bottom: 20
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20.0, left: 10.0),
                            child: Image.asset(
                                "assets/images/flag.png", width: 22,
                                height: 22),
                          ),
                        ]),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {
                        if(selectedLanguage.value == 'Select language' || selectedLanguage.value == 'Sélectionnez la langue' ){
                          Get.showSnackbar(Ui.warningSnackBar(message: AppLocalizations.of(context).please_select_language));
                        }
                        else{
                          Navigator.of(context).pop();
                        }

                      }, child: Text('Save', style: TextStyle(color: interfaceColor),)),
                    )

                  ],).paddingAll(20),
              )
          );

    }

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
      ScaffoldMessenger.of(Get.context!).showSnackBar( SnackBar(
        content: Text(AppLocalizations.of(Get.context!).loading_sectors),
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


    }});

// coverage:ignore-end
    super.onInit();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startProgress() {
    const int updatesPerSecond = 60; // Smooth updates per second
    final int totalUpdates = duration.inSeconds * updatesPerSecond;
    final double increment = 1.0 / totalUpdates;

    int updateCount = 0;

    _timer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ updatesPerSecond),
          (timer) {

          progress.value += increment;

        updateCount++;
        if (updateCount >= totalUpdates) {
          _timer?.cancel();
          Get.offAllNamed(Routes.LOGIN);
        }
      },
    );
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

  profileImagePicker(String source) async {
    if(source=='camera'){
      final XFile? pickedImage =
      await picker.pickImage(source: ImageSource.camera);
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
          currentUser.value.imageFile = profileImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        else{
          profileImage = File(pickedImage.path);
          currentUser.value.imageFile = profileImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        Navigator.of(Get.context!).pop();
        //Get.showSnackbar(Ui.SuccessSnackBar(message: "Picture saved successfully".tr));
        //loadIdentityFile.value = !loadIdentityFile.value;//Navigator.of(Get.context).pop();
      }

    }
    else{
      final XFile? pickedImage =
      await picker.pickImage(source: ImageSource.gallery);
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
          currentUser.value.imageFile = profileImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        else{
          print(pickedImage);
          profileImage = File(pickedImage.path);
          currentUser.value.imageFile = profileImage;
          loadProfileImage.value = !loadProfileImage.value;

        }
        Navigator.of(Get.context!).pop();
      }

    }
  }

  register() async {

    try {
      loading.value = true;
      currentUser.value = await userRepository.register(currentUser.value);
      Get.find<AuthService>().user.value = currentUser.value;
      box.write("authToken",Get.find<AuthService>().user.value.authToken );
      box.write("current_user", Get.find<AuthService>().user.value.toJson()
      );
     if(! Platform.environment.containsKey('FLUTTER_TEST')){
       await Get.find<RootController>().changePage(0);
       Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).account_created_successfully ));
     }

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }

    } finally {
      loading.value = false;
    }

  }

  registerInstitution() async {

    try {
      loading.value = true;
      var result = await userRepository.registerInstitution(currentUser.value);
      if(result['verified'] == false){
        box.write("authToken", result['token']);

      }


    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }

    } finally {
      loading.value = false;
    }

  }

  login() async {

      loading.value = true;
      try {
        var a = await userRepository.login(currentUser.value);
        if(a != null){
          Get.find<AuthService>().user.value.authToken = a.authToken;
          Get.find<AuthService>().user.value.userId = a.userId;
          Get.find<AuthService>().user.value.firstName = a.firstName;
          Get.find<AuthService>().user.value.lastName = a.lastName;
          Get.find<AuthService>().user.value.gender = a.gender;
          Get.find<AuthService>().user.value.phoneNumber = a.phoneNumber;
          Get.find<AuthService>().user.value.email = a.email;
          Get.find<AuthService>().user.value.avatarUrl = a.avatarUrl;
          Get.find<AuthService>().user.value.type = a.type;
          box.write("authToken",Get.find<AuthService>().user.value.authToken );
          box.write("current_user", Get.find<AuthService>().user.value.toJson());

          //update();

          Get.put(RootController());
          Get.lazyPut(()=>DashboardController());
          Get.lazyPut<CommunityController>(() => CommunityController());
          Get.lazyPut<NotificationController>(() => NotificationController());
          Get.lazyPut<EventsController>(() => EventsController());
          //loading.value = false;
          if(! Platform.environment.containsKey('FLUTTER_TEST')){
            print("Emaillllllllllllllllllll: ${Get.find<AuthService>().user.value.email}");
            Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).login_successful ));
            await Get.find<RootController>().changePage(0);
          }
        }




      }
      catch (e) {
        if(! Platform.environment.containsKey('FLUTTER_TEST')){
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }

      } finally {
        loading.value = false;
      }





  }

  getUser() async {

    try {
      var user = await userRepository.getUser();
      currentUser.value= user;
      currentUser.value.myPosts = user.myPosts;
      currentUser.value.myEvents = user.myEvents;
      currentUser.value.followerCount = user.followerCount;
      currentUser.value.followingCount = user.followingCount;
      currentUser.value.authToken = box.read("authToken");

      Get.find<AuthService>().user.value = currentUser.value;
      box.write("current_user", Get.find<AuthService>().user.value.toJson());
      print(user.toJson()['my_posts']);
      print('my podt : ${currentUser.value.myPosts}');
      //await Get.find<RootController>().changePage(0);
      //Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).profile_info_successful ));
    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } finally {
    }

  }
  logout() async {
      try {
        loading.value = true;
        await userRepository.logout();
        Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).logout_successful ));
        loading.value = false;
        await Get.toNamed(Routes.LOGIN);

      }
      catch (e) {
        loading.value = false;
        if(! Platform.environment.containsKey('FLUTTER_TEST')){
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }
      } finally {
        loading.value = false;
      }




  }

  deleteAccount() async {
    try {
      loading.value = true;
      await userRepository.deleteAccount();
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).delete_account_successful));
      loading.value = false;
      await Get.toNamed(Routes.LOGIN);

    }
    catch (e) {
      loading.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } finally {
      loading.value = false;
    }




  }


  resetPassword(String email) async {
    try {
      loading.value = true;
      await userRepository.resetPassword(email);
    }
    catch (e) {
      loading.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } finally {
      loading.value = false;
    }




  }


  getAllSectors() async{
    return sectorRepository.getAllSectors();
  }



}