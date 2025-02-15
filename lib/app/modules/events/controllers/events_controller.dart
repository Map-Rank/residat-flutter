
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapnrank/app/models/event_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/repositories/events_repository.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/common/ui.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

import 'package:path_provider/path_provider.dart';

import '../../../../color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EventsController extends GetxController {

  Rx<UserModel> currentUser = Get.find<AuthService>().user;
  var startingDate = "--/--/--".obs;
  var endingDate = "--/--/--".obs;
  late EventsRepository eventsRepository ;
  var allEvents = [].obs;
  var imageFiles = [].obs;
  var listAllEvents = [];
  var loadingEvents = true.obs;
  var createEvents = false.obs;
  var createUpdateEvents = false.obs;
  var updateEvents = false.obs;
  var searchField = false.obs;
  var noFilter = true.obs;
  var page = 0;
  late Event event;
  Event eventDetails = Event();
  late ScrollController scrollbarController;

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

  late UserRepository userRepository ;
  late ZoneRepository zoneRepository ;
  late SectorRepository sectorRepository ;

  var chooseARegion = false.obs;
  var chooseADivision = false.obs;
  var chooseASubDivision = false.obs;

  var inputImage = false.obs;
  var filterBySector = false.obs;
  var filterByLocation = false.obs;

  TextEditingController eventOrganizerController = TextEditingController();

  TextEditingController eventLocation = TextEditingController();

  TextEditingController startingDateDisplay = TextEditingController();

  TextEditingController endingDateDisplay = TextEditingController();



  EventsController(){
    Get.lazyPut(()=>CommunityController());
  }


  @override
  void onInit() async {
    eventsRepository = EventsRepository();
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();
    startingDateDisplay.text = "--/--/--";
    endingDateDisplay.text = "--/--/--";
    event = Event();

    scrollbarController = ScrollController()..addListener(_scrollListener);




// coverage:ignore-start
    if(! Platform.environment.containsKey('FLUTTER_TEST')){
      listAllEvents = await getAllEvents(0);
      allEvents.value= listAllEvents;


      var box = GetStorage();

      var boxRegions = box.read("allRegions");

      if(boxRegions == null){
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(Get.context!).loading_regions),
          duration: Duration(seconds: 3),
        ));

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


      }
    }
    else{
      listAllEvents = [Event(
        eventId: 1,
        title: "Flutter Conference",
        content: "An exciting conference about Flutter development.",
        zone: "Zone 1",
        organizer: "Tech World",
        publishedDate: "2024-09-01",
        imagesUrl: "https://example.com/event_image.jpg",
      )];
      allEvents.value= listAllEvents;
      loadingEvents = false.obs;
      createUpdateEvents = true.obs;

    }

// coverage:ignore-end
    super.onInit();

  }


  Future refreshEvents({bool showMessage = false}) async {
    listAllEvents.clear();
    allEvents.clear();
    loadingEvents.value = true;
    if(! Platform.environment.containsKey('FLUTTER_TEST')){
      listAllEvents = await getAllEvents(0);
    }
    else{
      listAllEvents = [Event(), Event()];
    }

    allEvents.value = listAllEvents;
    emptyArrays();
  }

  @override
  void dispose() {
    scrollbarController.removeListener(_scrollListener);
    super.dispose();
  }

  emptyArrays(){
     sectorsSelected.clear();
     imageFiles.clear();
     regionSelectedValue.clear();
     createUpdateEvents.value = false;
     divisionSelectedValue.clear();
     subdivisionSelectedValue.clear();
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
      event.imagesFileBanner = imageFiles;

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
        event.imagesFileBanner = imageFiles;


        i++;
      }
    }
  }


// coverage:ignore-start
  void _scrollListener() async{
    print('extent is ${scrollbarController.position.extentAfter}');
    if (scrollbarController.position.extentAfter < 10) {
      var event = await getAllEvents(++page);
      allEvents.addAll(event);
      listAllEvents.addAll(event);
    }
  }
// coverage:ignore-end



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
  getAllSectors() async{
    return sectorRepository.getAllSectors();
  }

  filterSearchEventsBySectors(var query) async {
    var eventsList = [];
    if(sectorsSelected.isNotEmpty) {
      loadingEvents.value = true;
      try {
        page = 0;
        var list = await eventsRepository.filterEventsBySectors(page, query);
        for( var i = 0; i< list.length; i++) {
          event = Event(
              zone: list[i]['location'],
              eventId: list[i]['id'].toInt(),
              content: list[i]['description'],
              publishedDate: list[i]['humanize_date_creation'],
              imagesUrl: list[i]['image'],
              title: list[i]['title'],
              eventCreatorId: int.parse(list[i]['user_id']),
              organizer: list[i]['organized_by'],
              eventSectors: list[i][''],
              startDate: list[i]['date_debut'],
              endDate: list[i]['date_fin']

            //sectors: list[i]['sectors']

          );

          //print(User.fromJson(list[i]['creator']));
          //if(list[i]['is_valid'] == "1"){
          eventsList.add(event);
          //}

        }
        loadingEvents.value = false;
        allEvents.value = eventsList;
        noFilter.value = false;
        return;

      }
      catch (e) {

        if(! Platform.environment.containsKey('FLUTTER_TEST')){
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }
      }
      finally {
        loadingEvents.value = false;


      }

    }else {
      allEvents.value = listAllEvents;
      noFilter.value = false;
    }
  }

  filterSearchEventsByZone(var query)async{
    var eventList = [];
    if(divisionSelectedValue.isNotEmpty || regionSelectedValue.isNotEmpty || subdivisionSelectedValue.isNotEmpty) {
      loadingEvents.value = true;
      try {
        page = 0;
        var list = await eventsRepository.filterEventsByZone(page, query);
        print(list);
        for( var i = 0; i< list.length; i++){
          event = Event(
              zone: list[i]['location'],
              eventId: list[i]['id'].toInt(),
              content: list[i]['description'],
              publishedDate: list[i]['humanize_date_creation'],
              imagesUrl: list[i]['image'],
              title: list[i]['title'],
              eventCreatorId: list[i]['user_id'],
              organizer: list[i]['organized_by'],
              eventSectors: list[i][''],
              startDate: list[i]['date_debut'],
              endDate: list[i]['date_fin']);


              //print(User.fromJson(list[i]['creator']));
          eventList.add(event);
        }
        loadingEvents.value = false;
        allEvents.value = eventList;
        noFilter.value = false;
        return;

      }
      catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
      finally {
        loadingEvents.value = false;


      }

    }else {
      loadingEvents.value = true;
      listAllEvents = await getAllEvents(0);
      allEvents.value = listAllEvents;
      noFilter.value = false;
    }
  }

  filterSearchEventsBySubdivisionZone(String query){
    List dummySearchList = [];
    dummySearchList = listAllEvents;

    if(subdivisionSelectedValue.isNotEmpty) {
      List dummyListData = [];
      for (int j = 0; j < dummySearchList.length; j++) {
        if (dummySearchList[j].zone['id'].toString() ==
            subdivisionSelectedValue[0]['id'].toString()) {
          dummyListData.add(dummySearchList[j]);


        }

      }

      allEvents.value = dummyListData;
      noFilter.value = false;
      return;
    }else {

      filterSearchEventsByDivisionZone(query);
      //allPosts.value = listAllPosts;
      //noFilter.value = false;
    }
  }

  filterSearchEventsByDivisionZone(String query){
    List dummySearchList = [];
    dummySearchList = listAllEvents;

    if(divisionSelectedValue.isNotEmpty) {
      List dummyListData = [];
      for (int j = 0; j < dummySearchList.length; j++) {
        if (dummySearchList[j].zone['id'].toString() ==
            divisionSelectedValue[0]['id'].toString()) {
          dummyListData.add(dummySearchList[j]);


        }

      }

      allEvents.value = dummyListData;
      noFilter.value = false;
      return;
    }else {
      filterSearchEventsByRegionZone(query);
      //allPosts.value = listAllPosts;
      noFilter.value = false;
    }
  }

  filterSearchEventsByRegionZone(String query){
    List dummySearchList = [];
    dummySearchList = listAllEvents;

    if(regionSelectedValue.isNotEmpty) {
      List dummyListData = [];
      for (int j = 0; j < dummySearchList.length; j++) {
        if (dummySearchList[j].zone['id'].toString() ==
            regionSelectedValue[0]['id'].toString()) {
          dummyListData.add(dummySearchList[j]);


        }

      }

      allEvents.value = dummyListData;
      noFilter.value = false;
      return;
    }else {

      allEvents.value = listAllEvents;
      noFilter.value = false;
    }
  }

  getSpecificZone(int zoneId){
    try{
      var result = zoneRepository.getSpecificZone(zoneId);
      return result;
    }
    catch(e){
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }

  }

  getAllEvents(int page)async{
    var eventsList = [];
    try{

      var list = await eventsRepository.getAllEvents(page);
      print('List is: $list');

      for( var i = 0; i< list.length; i++) {
        var event = Event(
            zone: list[i]['location'],
            eventId: list[i]['id'].toInt(),
            content: list[i]['description'],
            publishedDate: list[i]['humanize_date_creation'],
            imagesUrl: list[i]['image'],
            title: list[i]['title'],
            eventCreatorId: list[i]['user_id'],
            organizer: list[i]['organized_by'],
            eventSectors: list[i]['sector'],
            startDate: list[i]['date_debut'],
            endDate: list[i]['date_fin'],
            zoneParentId: list[i]['zone']['parent_id'],
            zoneLevelId: list[i]['zone']['level_id'],
            zoneEventId: list[i]['zone']['id'],
            //sectors: list[i]['sectors']

        );
        print(list[i]['sector']);
        print(event.eventSectors);

        //print(User.fromJson(list[i]['creator']));
        //if(list[i]['is_valid'] == "1"){
          eventsList.add(event);
        //}

      }
      loadingEvents.value = false;
      return eventsList;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {


    }

  }

  getAnEvent(int eventId)async{
    try{
      var result= await eventsRepository.getAnEvent(eventId);
      print("Result is : ${result}");
      Event eventModel = Event(
          zone: result['location'],
          eventId: result['id'].toInt(),
          content: result['description'],
          publishedDate: result['published_at'],
          imagesUrl: result['image'],
          title: result['title'],
          eventCreatorId: int.parse(result['user_id']),
          organizer: result['organized_by'],
        zoneParentId: result['zone']['parent_id'],
        zoneLevelId: result['zone']['level_id'], //sectors: list[i]['sectors']

      );
      eventModel.sectors = result['sector'].toList();
      return eventModel;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {

    }

  }
  createEvent(Event event)async{
    try{

      await eventsRepository.createEvent(event);
      loadingEvents.value = true;
      listAllEvents = await getAllEvents(0);
      allEvents.value = listAllEvents;
      createEvents.value = true;
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).event_created_successful ));
      Navigator.pop(Get.context!);

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      createEvents.value = true;
      emptyArrays();


    }

  }

  updateEvent(Event event)async{
    try{
      await eventsRepository.updateEvent(event);
      listAllEvents.clear();
      allEvents.clear();
      loadingEvents.value = true;
      listAllEvents = await getAllEvents(0);
      allEvents.value = listAllEvents;
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).event_updated_successful ));
      emptyArrays();
      Navigator.pop(Get.context!);

    }
    catch (e) {
      updateEvents.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      updateEvents.value = false;
      emptyArrays();
    }

  }



  deleteEvent(int eventId)async{
    try{
      await eventsRepository.deleteEvent(eventId);
      Get.showSnackbar(Ui.SuccessSnackBar(message: AppLocalizations.of(Get.context!).event_deleted_successful ));
      loadingEvents.value = true;
      listAllEvents = await getAllEvents(0);
      allEvents.value = listAllEvents;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      //createPosts.value = true;
    }

  }

}


