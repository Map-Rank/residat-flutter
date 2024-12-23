// coverage:ignore-file
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';


class AuthService extends GetxService {
  var user = UserModel().obs;
  GetStorage? _box;

  UserRepository? _usersRepo;

  AuthService() {
    _usersRepo = UserRepository();
    _box = GetStorage();
  }

  Future<AuthService> init() async {
    user.listen((UserModel user) {
      _box?.write('current_user', user.toJson());
    });
    await getCurrentUser();
    return this;
  }

  Future getCurrentUser() async {
    if (UserModel.auth == null && _box!.hasData('current_user')) {
      user.value = UserModel.fromJson(await _box?.read('current_user'));
      print('User is :   ${user.value}');
      UserModel.auth = true;
    } else {
      UserModel.auth = false;
    }
  }

  Future removeCurrentUser() async {
    user.value =  UserModel();
    await _usersRepo?.logout();
    await _box?.remove('current_user');
  }

  bool get isAuth => UserModel.auth ?? false;





  //String get apiToken => (user.value.auth ?? false) ? user.value.apiToken : '';
}
