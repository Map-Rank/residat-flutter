import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import '../../../../common/ui.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../community/controllers/community_controller.dart';





class OtherUserProfileController extends GetxController {
  Rx<UserModel> currentUser = UserModel().obs;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  var allPosts = [].obs;
  var listAllPosts = [];
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

  var updateUserInfo = false.obs;
  var picker = ImagePicker();
  late Rx<File> profileImage = File('assets/images/loading.gif').obs ;
  final loadProfileImage = false.obs;

  late File feedbackImage = File('assets/images/loading.gif') ;
  final loadFeedbackImage = false.obs;




  @override
  void onInit() async {
    userRepository = UserRepository();

    var arguments = Get.arguments as Map<String, dynamic>;
    if(arguments!= null) {
      if (arguments['userId'] != null) {
        var userId = arguments['userId'];

        await getAnotherUserProfile(userId);

        firstNameController.text = currentUser.value.firstName!;
        lastNameController.text = currentUser.value.lastName!;
        emailController.text = currentUser.value.email!;
        phoneNumberController.text = currentUser.value.phoneNumber!;
        genderController.text = currentUser.value.gender!;
        birthdateController.text = currentUser.value.gender!;
      }
    }


    super.onInit();
  }


  getAnotherUserProfile(int userId) async {
    print('ghvghjshdjkjdfl;kfkldjfdlsfjkkjrshkljflksjfs');

    try {
      loadingPosts.value = false;
      var user = await userRepository.getAnotherUserProfile(userId);
      print('User is : $user');
      currentUser.value = user;
      currentUser.value.authToken = user.authToken;
      currentUser.value.userId = user.userId;
      currentUser.value.firstName = user.firstName;
      currentUser.value.lastName = user.lastName;
      currentUser.value.gender = user.gender;
      currentUser.value.phoneNumber = user.phoneNumber;
      currentUser.value.email = user.email;
      currentUser.value.avatarUrl = user.avatarUrl;
      currentUser.value.myPosts = user.myPosts;
      currentUser.value.followerCount = user.followerCount;
      currentUser.value.followingCount = user.followingCount;

        listAllPosts = await getAllMyPosts()??[];
        allPosts.value =  listAllPosts;
     
      loadingPosts.value = true;
    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } finally {
    }

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
            commentCount: RxInt(list[i]['comment_count']),
            likeCount: RxInt(list[i]['like_count']),
            shareCount: RxInt(list[i]['share_count']),
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

  initializePostDetails(Post post){
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




}


