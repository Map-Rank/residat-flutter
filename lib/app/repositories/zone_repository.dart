// coverage:ignore-file
import 'package:get/get.dart';
import 'package:mapnrank/app/models/user_model.dart';
import '../providers/laravel_provider.dart';

class ZoneRepository {
  late LaravelApiClient _laravelApiClient;


  Future getCameroonGeoJson() {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getCameroonGeoJson()  ;
  }

  Future getSpecificZoneGeoJson(String url) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getSpecificZoneGeoJson(url)  ;
  }


  Future getAllRegions(int levelId, int parentId) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllZones(levelId, parentId);
  }

  Future getAllDivisions(int levelId, int parentId) async{
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllZones(levelId, parentId);
  }
  Future getAllSubdivisions(int levelId, int parentId) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllZones(levelId, parentId);
  }

  Future getSpecificZone(int zoneId){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getSpecificZone(zoneId);
  }

  Future getSpecificZoneByName(String name){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getSpecificZoneByName(name);
  }

  Future getAllZonesFilterByName(){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllZonesFilterByName();
  }

  Future getDisastersMarkers(){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getDisasterMarkers();
  }

}
