// coverage:ignore-file
import 'package:get/get.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import '../models/event_model.dart';
import '../providers/laravel_provider.dart';

class EventsRepository {
  late LaravelApiClient _laravelApiClient;



   getAllEvents(int page) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAllEvents(page);
  }
  Future filterEventsByZone(int page, int zoneId) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.filterEventsByZone(page, zoneId);
  }

  Future filterEventsBySectors(int page, var sectors) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.filterEventsBySectors(page, sectors);
  }

  Future createEvent(Event event) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.createEvent(event);

  }

  Future updateEvent(Event event) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.updateEvent(event);
  }


  Future deleteEvent(int eventId){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.deleteEvent(eventId);

  }

  Future getAnEvent(int eventId){
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getAnEvent(eventId);

  }

}
