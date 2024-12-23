// coverage:ignore-file
import 'package:get/get.dart';
import 'package:mapnrank/app/models/feedback_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import '../providers/laravel_provider.dart';

class UserRepository {
   late LaravelApiClient _laravelApiClient;
  Future login(UserModel user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.login(user);
  }

   Future logout<int>() {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.logout();
   }

   Future deleteAccount<int>() {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.deleteAccount();
   }

   Future checkTokenValidity(String token) {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.checkTokenValidity(token);
   }



  Future register(UserModel user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.register(user);
  }

   Future registerInstitution(UserModel user) {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.registerInstitution(user);
   }

   Future  getUser() {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.getUser();
   }

   Future  getAnotherUserProfile(int userId) {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.getAnotherUserProfileInfo(userId);
   }

   Future updateUser(UserModel user) {
     _laravelApiClient = Get.find<LaravelApiClient>();
     return _laravelApiClient.updateUser(user);
   }

  Future signOut() async {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return await _laravelApiClient.logout();
  }

  Future resetPassword(String email) async {
    _laravelApiClient = Get.find<LaravelApiClient>();
    await _laravelApiClient.resetPassword(email);
  }

   Future followUser(int userId) async {
     _laravelApiClient = Get.find<LaravelApiClient>();
     await _laravelApiClient.followUser(userId);
   }

   Future unfollowUser(int userId) async {
     _laravelApiClient = Get.find<LaravelApiClient>();
     await _laravelApiClient.unfollowUser(userId);
   }

   Future sendFeedback(FeedbackModel feedbackModel) async {
     _laravelApiClient = Get.find<LaravelApiClient>();
     await _laravelApiClient.sendFeedback(feedbackModel);
   }
}
