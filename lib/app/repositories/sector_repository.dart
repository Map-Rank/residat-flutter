// coverage:ignore-file
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import '../providers/laravel_provider.dart';

class SectorRepository {
  late LaravelApiClient _laravelApiClient;



  Future getAllSectors() {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllSectors();
  }

}
