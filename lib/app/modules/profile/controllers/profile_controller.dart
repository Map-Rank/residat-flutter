import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../common/ui.dart';
import '../../../models/event_model.dart';
import '../../../models/feedback_model.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/global_services.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/widgets/comment_loading_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../events/controllers/events_controller.dart';




class ProfileController extends GetxController {
  Rx<UserModel> currentUser = Get.find<AuthService>().user;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();


  var allPosts = [].obs;
  var listAllPosts = [];
  var allEvents = [].obs;
  var listAllEvents = [];
  var loadingPosts = true.obs;
  var likeTapped = false.obs;

  var selectedPost = [].obs;

  var unlikedPost = [].obs;

  var sharedPost = [].obs;

  var postSelectedIndex = 0.5.obs;

  var postFollowedIndex = 0.obs;

  var postSharedIndex = 0.obs;

  RxInt? likeCount = 0.obs;
  RxInt? shareCount = 0.obs;
  RxInt? commentCount = 0.obs;

  var comment = ''.obs;
  var sendComment = false.obs;

  var commentList = [].obs;

  Rx<Post> postDetails = Post().obs;

  late ScrollController scrollbarController;


  var rating = 0.obs;

  late UserRepository userRepository ;
  late ZoneRepository zoneRepository ;
  late SectorRepository sectorRepository ;
  var updateUserInfo = false.obs;
  var picker = ImagePicker();
  late Rx<File> profileImage = File('assets/images/loading.gif').obs ;
  final loadProfileImage = false.obs;

  late File feedbackImage = File('assets/images/loading.gif') ;
  final loadFeedbackImage = false.obs;



  ProfileController() {

  }

  @override
  void onInit() async {
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();
    firstNameController.text = currentUser.value.firstName!;
    lastNameController.text = currentUser.value.lastName!;
    emailController.text = currentUser.value.email!;
    phoneNumberController.text = currentUser.value.phoneNumber!;
    genderController.text = currentUser.value.gender!;
    birthdateController.text = currentUser.value.birthdate!;

      listAllPosts = await getAllMyPosts()??[];
      allPosts.value =  listAllPosts;

      listAllEvents = await getAllMyEvents()??[];
      allEvents.value = listAllEvents;



    super.onInit();
  }

  Future refreshProfile({bool showMessage = false}) async {
    currentUser.value =  await Get.find<AuthController>().getUser();
  }

  getAllMyPosts() {
    var postList = [];
    if(! Platform.environment.containsKey('FLUTTER_TEST')){
      Get.find<CommunityController>()
          .sharedPost
          .clear();
    }


    try {
      var list = currentUser.value.myPosts!;
      print("list is ${currentUser.value.myPosts}");
      for (var i = 0; i < list.length; i++) {
        var post = Post(
            zone: list[i]['zone'],
            postId: list[i]['id'],
            commentCount: RxInt(list[i] ['comment_count']),
            likeCount: RxInt(list[i] ['like_count']),
            shareCount: RxInt(list[i] ['share_count']),
            content: list[i]['content'],
            publishedDate: list[i]['humanize_date_creation'],
            imagesUrl: list[i]['images'],
            liked: list[i]['liked'],
            likeTapped: RxBool(list[i]['liked']),
            sectors: list[i]['sectors'],
            isFollowing: RxBool(list[i]['is_following'])


        );

        //print(User.fromJson(list[i]['creator']));
        postList.add(post);
      }
      return postList;
    } catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }

    }
  }

  initializeMyPostDetails(Post post){
    Get.find<CommunityController>().postDetails.value.content = post.content;
    Get.find<CommunityController>().postDetails.value.zone = post.zone;
    Get.find<CommunityController>().postDetails.value.postId = post.postId;
    Get.find<CommunityController>().postDetails.value.commentCount = post.commentCount;
    Get.find<CommunityController>().postDetails.value.likeCount = post.likeCount;
    Get.find<CommunityController>().postDetails.value.shareCount = post.shareCount;
    Get.find<CommunityController>().postDetails.value.publishedDate = post.publishedDate;
    Get.find<CommunityController>().postDetails.value.imagesUrl = post.imagesUrl;
    Get.find<CommunityController>().postDetails.value.user = post.user;
    Get.find<CommunityController>().postDetails.value.liked = post.liked;
    Get.find<CommunityController>().postDetails.value.likeTapped = post.likeTapped;
    Get.find<CommunityController>().postDetails.value.isFollowing = post.isFollowing;
    Get.find<CommunityController>().postDetails.value.commentList = post.commentList;
    Get.find<CommunityController>().postDetails.value.sectors = post.sectors;
    Get.find<CommunityController>().postDetails.value.zonePostId = post.zonePostId;
    Get.find<CommunityController>().postDetails.value.zoneLevelId = post.zoneLevelId;
    Get.find<CommunityController>().postDetails.value.zoneParentId = post.zoneParentId;
    likeCount?.value = post.likeCount!.value;
    shareCount?.value =post.shareCount!.value;
  }

  getAllMyEvents(){
    var eventsList = [];
    try{

      var list = currentUser.value.myEvents!;
      print('List is: $list');

      for( var i = 0; i< list.length; i++) {
        var event = Event(
          zone: list[i]['location'],
          eventId: list[i]['id'].toInt(),
          content: list[i]['description'],
          publishedDate: list[i]['published_at'],
          imagesUrl: list[i]['media'],
          title: list[i]['title'],
          eventCreatorId: list[i]['user_id'],
          organizer: list[i]['organized_by'],
          eventSectors: list[i]['sector'],
          startDate: list[i]['date_debut'],
          endDate: list[i]['date_fin'],
          //zoneParentId: list[i]['zone']['parent_id'],
          // zoneLevelId: list[i]['zone']['level_id'],
          // zoneEventId: list[i]['zone']['id'],
          //sectors: list[i]['sectors']

        );
        print(list[i]['image']);
        print(event.eventSectors);

        //print(User.fromJson(list[i]['creator']));
        //if(list[i]['is_valid'] == "1"){
        eventsList.add(event);
        //}

      }
      return eventsList;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
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
          profileImage.value= compressedImage;
          currentUser.value.imageFile = profileImage.value;

        }
        else{
          profileImage.value = File(pickedImage.path);
          currentUser.value.imageFile = profileImage.value;

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
          profileImage.value= compressedImage;
          currentUser.value.imageFile = profileImage.value;

        }
        else{
          print(pickedImage);
          profileImage.value = File(pickedImage.path);
          currentUser.value.imageFile = profileImage.value;

        }
        Navigator.of(Get.context!).pop();
      }

    }
  }

  updateUser() async {

    try {
      updateUserInfo.value = true;
      var user = await userRepository.updateUser(currentUser.value);
      print(user);
      currentUser.value= user;
      // currentUser.value.myPosts = user.myPosts;
      // currentUser.value.myEvents = user.myEvents;

      Get.find<AuthService>().user.value = currentUser.value;
      await Get.find<AuthController>().getUser();

      //await Get.find<RootController>().changePage(0);
      updateUserInfo.value = false;
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).profile_info_updated_successful ));
    }
    catch (e) {
      updateUserInfo.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }

    } finally {
      updateUserInfo.value = false;
    }

  }

  feedbackImagePicker(String source) async {
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
          feedbackImage = compressedImage;
          loadFeedbackImage.value = !loadFeedbackImage.value;

        }
        else{
          feedbackImage = File(pickedImage.path);
          loadFeedbackImage.value = !loadFeedbackImage.value;

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
          feedbackImage = compressedImage;
          currentUser.value.imageFile = feedbackImage;
          loadFeedbackImage.value = !loadFeedbackImage.value;

        }
        else{
          print(pickedImage);
          feedbackImage = File(pickedImage.path);
          currentUser.value.imageFile = feedbackImage;
          loadFeedbackImage.value = !loadFeedbackImage.value;

        }
        Navigator.of(Get.context!).pop();
      }

    }
  }

  void launchWhatsApp(String message) async {
    String url() {
      if (Platform.isAndroid) {
        // add the [https]
        return "https://wa.me/${GlobalService.contactUsNumber}/?text=${Uri.parse(message)}"; // new line
      } else {
        // add the [https]
        return "https://api.whatsapp.com/send?phone=${GlobalService.contactUsNumber}=${Uri.parse(message)}"; // new line
      }
    }

    if (await canLaunchUrlString(url())) {
      await launchUrlString(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }


  sendFeedback()async{
    try{
      showDialog(context: Get.context!, builder: (context){
        return CommentLoadingWidget();
      },);
      await userRepository.sendFeedback(
          FeedbackModel(
              feedbackText: feedbackController.text,
              imageFile: feedbackImage,
              rating: rating.toString()
          ));
      Navigator.of(Get.context!).pop();
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).feedback_created_successful ));

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }

    }
    finally {

    }

  }
}


