
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/feedback_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/community/widgets/comment_loading_widget.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/app/repositories/community_repository.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:mapnrank/common/ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Im;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:math' as Math;
import '../../../models/post_model.dart';
import '../../root/controllers/root_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




class CommunityController extends GetxController {

  final Rx<UserModel> currentUser = Get.find<AuthService>().user;
  var floatingActionButtonTapped = false.obs;
  var loadingAPost = false.obs;
  late CommunityRepository communityRepository ;
  var allPosts = [].obs;
  var listAllPosts = [];
  var loadingPosts = true.obs;
  var createPosts = false.obs;
  var createUpdatePosts = false.obs;
  var updatePosts = false.obs;
  var searchField = false.obs;
  var noFilter = true.obs;
  var createPostNotEvent = true.obs;
  late Post post;
  Rx<Post> postDetails = Post().obs;
  List<Map<String, dynamic>> zones = [];
  List<Map<String, dynamic>> listAllZones = [];
  var loadingRegions = true.obs;
  var regions = [].obs;
  var regionSelected = false.obs;
  var regionSelectedIndex = 0.obs;
  var listRegions = [].obs;
  var regionsSet ={};
  var regionSelectedValue = [].obs;
  var cancelSearchSubDivision = false.obs;

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
  var postFollowed = [].obs;
  var postUnFollowed = [].obs;
  var selectedIndex = 0.obs;
  var listSectors = [].obs;
  var sectorsSet ={};

  var page = 0;

  RxBool registerNextStep1 = false.obs;

  late UserRepository userRepository ;
  late ZoneRepository zoneRepository ;
  late SectorRepository sectorRepository ;

  late Post postModel;

  late ScrollController scrollbarController;

  var imageFiles = [].obs;

  var isRootFolder = false;

  var likeTapped = false.obs;

  var selectedPost = [].obs;

  var unlikedPost = [].obs;

  var sharedPost = [].obs;

  var postSelectedIndex = 0.5.obs;

  var postFollowedIndex = 0.obs;

  var postSharedIndex = 0.obs;

  var comment = ''.obs;
  var sendComment = false.obs;

  var commentList = [].obs;

  var likeMyPost = false.obs;
  var shareMyPost = false.obs;

  TextEditingController commentController = TextEditingController();
  TextEditingController postContentController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();


  var rating = 0.obs;


  RxInt? likeCount = 0.obs;
  RxInt? shareCount = 0.obs;
  RxInt? commentCount = 0.obs;

  var copyLink = false.obs;
  var chooseARegion = false.obs;
  var chooseADivision = false.obs;
  var chooseASubDivision = false.obs;

  var inputImage = false.obs;
  var filterBySector = false.obs;
  var filterByLocation = false.obs;

  var picker = ImagePicker();
  late File feedbackImage = File('assets/images/loading.gif') ;
  final loadFeedbackImage = false.obs;



  CommunityController() {

  }

  @override
  void onInit() async {

    super.onInit();

    post = Post();
    print('Post from init: ${post.content}' );

    scrollbarController = ScrollController()..addListener(_scrollListener);
    communityRepository = CommunityRepository();
    userRepository = UserRepository();
    zoneRepository = ZoneRepository();
    sectorRepository = SectorRepository();



    await refreshCommunity();
    if(! Platform.environment.containsKey('FLUTTER_TEST')){
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

        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
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
      allPosts = [Post(
        content: 'Test post content',
        zone: {'name': 'Test Zone'},
        publishedDate: DateTime.now().toString(),
        postId: 1,
        imagesUrl: [
            {'url': ''}
          ],
        user: UserModel(
          firstName: 'Test',
          lastName: 'User',
          avatarUrl: 'https://example.com/avatar.png',
        ),
        commentCount: RxInt(5),
        shareCount: RxInt(10),
        likeCount: RxInt(100),
        likeTapped: false.obs,
        isFollowing: false.obs,

      )].obs;

      loadingPosts = false.obs;
      createUpdatePosts = true.obs;
      post = Post(
        content: 'Test post content',
        zone: {'name': 'Test Zone'},
        publishedDate: DateTime.now().toString(),
        postId: 1,
        imagesUrl: [
          {'url': 'testUrl'}
        ],
        user: UserModel(
          firstName: 'Test',
          lastName: 'User',
          avatarUrl: 'https://example.com/avatar.png',
        ),
        commentCount: RxInt(5),
        shareCount: RxInt(10),
        likeCount: RxInt(100),
        likeTapped: false.obs,
        isFollowing: false.obs,

      );
      //imageFiles = [];
    }

    var listZones = await getAllZonesFilterByName()??[];

    listAllZones = listZones.cast<Map<String, dynamic>>();
    zones = listAllZones;



  }


  @override
  void dispose() {
    scrollbarController.removeListener(_scrollListener);
    super.dispose();
  }

  refreshCommunity({bool showMessage = false}) async {
    selectedPost.clear();
    listAllPosts.clear();
    allPosts.clear();
    loadingPosts.value = true;
    if(! Platform.environment.containsKey('FLUTTER_TEST')){
      listAllPosts = await getAllPosts(0);
    }
    else{
      listAllPosts = [];
    }

    allPosts.value= listAllPosts;
    emptyArrays();
  }

  void _scrollListener() async{
    print('extent is ${scrollbarController.position.extentAfter}');
    if (scrollbarController.position.extentAfter < 10) {
      var posts = await getAllPosts(++page);
        allPosts.addAll(posts);
      listAllPosts.addAll(posts);
    }
  }

  getAllPosts(int page)async{
    print('page is :${page}');
    var postList = [];
    sharedPost.clear();

    try{
      var list = await communityRepository.getAllPosts(page);
      print(list);
      for( var i = 0; i< list.length; i++){
        UserModel user = UserModel(
            userId: list[i]['creator'][0]['id'],
            lastName:list[i]['creator'][0]['last_name'],
            firstName: list[i]['creator'][0]['first_name'],
            avatarUrl: list[i]['creator'][0]['avatar']
        );
        var post = Post(
            zone: list[i]['zone'],
            postId: list[i]['id'],
            commentCount:RxInt(list[i] ['comment_count']),
            likeCount:RxInt(list[i] ['like_count']) ,
            shareCount:RxInt(list[i] ['share_count']),
            content: list[i]['content'],
            publishedDate: list[i]['humanize_date_creation'],
            imagesUrl: list[i]['images'],
            user: user,
            liked: list[i]['liked'],
            likeTapped: RxBool(list[i]['liked']),
            sectors: list[i]['sectors'],
            isFollowing: RxBool(list[i]['is_following'])


        );

        print(list[i]['liked']);
        postList.add(post);
      }
      loadingPosts.value = false;
      return postList;

    }
    catch (e) {
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      loadingPosts.value = false;


    }

  }

  filterSearchPostsBySectors(var query)async{
    var postList = [];
    if(sectorsSelected.isNotEmpty) {
      loadingPosts.value = true;
      try {
        page = 0;
        var list = await communityRepository.filterPostsBySectors(page, query);
        print(list);
        for( var i = 0; i< list.length; i++){
          UserModel user = UserModel(userId: list[i]['creator'][0]['id'],
              lastName:list[i]['creator'][0]['last_name'],
              firstName: list[i]['creator'][0]['first_name'],
              avatarUrl: list[i]['creator'][0]['avatar']
          );
          post = Post(
            zone: list[i]['zone'],
            postId: list[i]['id'],
            commentCount:RxInt(list[i] ['comment_count']),
            likeCount:RxInt(list[i] ['like_count']) ,
            shareCount:RxInt(list[i] ['share_count']),
            content: list[i]['content'],
            publishedDate: list[i]['humanize_date_creation'],
            imagesUrl: list[i]['images'],
            user: user,
            liked: list[i]['liked'],
            likeTapped: RxBool(list[i]['liked']),
            sectors: list[i]['sectors'],
            isFollowing: RxBool(list[i]['is_following'])


          );

          //print(User.fromJson(list[i]['creator']));
          postList.add(post);
        }
        loadingPosts.value = false;
        allPosts.value = postList;
        noFilter.value = false;
        return;

      }
      catch (e) {
        if(! Platform.environment.containsKey('FLUTTER_TEST')){
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }
      }
      finally {
        loadingPosts.value = false;


      }

    }else {
      allPosts.value = listAllPosts;
      noFilter.value = false;
    }
  }

  filterSearchPostsByZone(var query)async{
    var postList = [];
    if(divisionSelectedValue.isNotEmpty || regionSelectedValue.isNotEmpty || subdivisionSelectedValue.isNotEmpty || !noFilter.value) {
      loadingPosts.value = true;
      try {
        page = 0;
        var list = await communityRepository.filterPostsByZone(page, query);
        print(list);
        for( var i = 0; i< list.length; i++){
          UserModel user = UserModel(userId: list[i]['creator'][0]['id'],
              lastName:list[i]['creator'][0]['last_name'],
              firstName: list[i]['creator'][0]['first_name'],
              avatarUrl: list[i]['creator'][0]['avatar']
          );
          post = Post(
            zone: list[i]['zone'],
            postId: list[i]['id'],
            commentCount:RxInt(list[i] ['comment_count']),
            likeCount:RxInt(list[i] ['like_count']) ,
            shareCount:RxInt(list[i] ['share_count']),
            content: list[i]['content'],
            publishedDate: list[i]['humanize_date_creation'],
            imagesUrl: list[i]['images'],
            user: user,
            liked: list[i]['liked'],
            likeTapped: RxBool(list[i]['liked']),
            sectors: list[i]['sectors'], 
            isFollowing: RxBool(list[i]['is_following']),


          );

          //print(User.fromJson(list[i]['creator']));
          postList.add(post);
        }
        loadingPosts.value = false;
        allPosts.value = postList;
        noFilter.value = false;
        return;

      }
      catch (e) {
        if(! Platform.environment.containsKey('FLUTTER_TEST')){
          Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
        }
      }
      finally {
        loadingPosts.value = false;


      }

    }else {
      loadingPosts.value = true;
      listAllPosts = await getAllPosts(0);
      allPosts.value = listAllPosts;
      noFilter.value = false;
    }
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
  getAllSectors() async{
    return sectorRepository.getAllSectors();
  }

  Future  pickImage(ImageSource source) async {

    ImagePicker imagePicker = ImagePicker();

    if(source.toString() == ImageSource.camera.toString())
    {
      var compressedImage;
      XFile? pickedFile = await imagePicker.pickImage(source: source, imageQuality: 80);
      File imageFile = File(pickedFile!.path);
      if(imageFile.lengthSync()>pow(1024, 2)){
        final tempDir = await getTemporaryDirectory();
        final path = tempDir.path;
        int rand = Math.Random().nextInt(10000);
        Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
        compressedImage = File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));


      }
      else{

        compressedImage = File(pickedFile.path);

      }

        imageFiles.add(compressedImage) ;
      post.imagesFilePaths = imageFiles;

    }
    else{
      var compressedImage;
      var i =0;
      var galleryFiles = await imagePicker.pickMultiImage();

      while(i<galleryFiles.length){
        File imageFile = File(galleryFiles[i].path);
        if(imageFile.lengthSync()>pow(1024, 2)){
          final tempDir = await getTemporaryDirectory();
          final path = tempDir.path;
          int rand = Math.Random().nextInt(10000);
          Im.Image? image1 = Im.decodeImage(imageFile.readAsBytesSync());
          compressedImage =  File('${path}/img_$rand.jpg')..writeAsBytesSync(Im.encodeJpg(image1!, quality: 25));


        }
        else{

          compressedImage = File(galleryFiles[i].path);

        }


        imageFiles.add(compressedImage) ;
        post.imagesFilePaths = imageFiles;


        i++;
      }
    }
  }

  selectCameraOrGalleryFeedbackImage(){
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
                        await feedbackImagePicker('camera');
                        //Navigator.pop(Get.context);


                      },
                      leading: const Icon(FontAwesomeIcons.camera),
                      title: Text( AppLocalizations.of(Get.context!).take_picture, style: Get.textTheme.headlineMedium?.merge(const TextStyle(fontSize: 15))),
                    ),
                    ListTile(
                      onTap: ()async{
                        await feedbackImagePicker('gallery');
                        //Navigator.pop(Get.context);

                      },
                      leading: const Icon(FontAwesomeIcons.image),
                      title: Text( AppLocalizations.of(Get.context!).upload_image
                          , style: Get.textTheme.headlineMedium?.merge(const TextStyle(fontSize: 15))),
                    )
                  ],
                )
            ),
          );
        });
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

  getAllZonesFilterByName() async{
    try{
      var result = await zoneRepository.getAllZonesFilterByName();
      return result;
    }
    catch(e){
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }

  }



  emptyArrays(){
    //postContentController.clear();
    postFollowed.clear();
    postUnFollowed.clear();
    sectorsSelected.clear();
    imageFiles.clear();
    regionSelectedValue.clear();
    divisionSelectedValue.clear();
    createUpdatePosts.value = false;
    subdivisionSelectedValue.clear();
  }

  createPost(Post post)async{
    try{
      createPosts.value = true;
      await communityRepository.createPost(post);
      listAllPosts.clear();
      allPosts.clear();
      loadingPosts.value = true;
      listAllPosts = await getAllPosts(0);
      allPosts.value = listAllPosts;
      createPosts.value = false;
      Get.showSnackbar(Ui.SuccessSnackBar(message:  AppLocalizations.of(Get.context!).post_created_successful ));
      if(isRootFolder){
        await Get.find<RootController>().changePage(0);
        postContentController.clear();
        emptyArrays();
        isRootFolder = false;
    }
      else{
        Navigator.pop(Get.context!);
      }

    }
    catch (e) {
      createPosts.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      createPosts.value = false;
      emptyArrays();


    }

  }

  updatePost(Post post)async{
    print(post.content);
    try{
      updatePosts.value = true;
      await communityRepository.updatePost(post);
      Get.showSnackbar(Ui.SuccessSnackBar(message:  AppLocalizations.of(Get.context!).post_updated_successful ));
      listAllPosts.clear();
      allPosts.clear();
      loadingPosts.value = true;
      listAllPosts = await getAllPosts(0);
      allPosts.value = listAllPosts;
      emptyArrays();
      Navigator.of(Get.context!).pop();

    }
    catch (e) {
      updatePosts.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {
      updatePosts.value = false;

    }

  }

  likeUnlikePost(int postId, int index,)async{
    try{
      await communityRepository.likeUnlikePost(postId);
      print('ok');

    }
    catch (e) {
      if(!likeMyPost.value) {
        allPosts
            .elementAt(index)
            .likeTapped
            .value = !allPosts
            .elementAt(index)
            .likeTapped
            .value;
        allPosts
            .elementAt(index)
            .likeCount
            .value = allPosts
            .elementAt(index)
            .likeCount
            .value - 1;
      }


      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
    finally {

    }

  }
  
  initializePostDetails(Post post) async{
    postDetails.value.content = post.content;
    postDetails.value.zone = post.zone;
    postDetails.value.postId = post.postId;
    postDetails.value.commentCount = post.commentCount;
    postDetails.value.likeCount = post.likeCount;
    postDetails.value.shareCount = post.shareCount;
    postDetails.value.publishedDate = post.publishedDate;
    postDetails.value.imagesUrl = post.imagesUrl;
    postDetails.value.user = post.user;
    postDetails.value.liked = post.liked;
    postDetails.value.likeTapped = post.likeTapped;
    postDetails.value.isFollowing = post.isFollowing;
    postDetails.value.commentList = post.commentList;
    postDetails.value.sectors = post.sectors;
    postDetails.value.zonePostId = post.zonePostId;
    postDetails.value.zoneLevelId = post.zoneLevelId;
    postDetails.value.zoneParentId = post.zoneParentId;
  }

  getAPost(int postId)async{
    try{
      loadingAPost.value = false;
      var result= await communityRepository.getAPost(postId);
      print("Result is : ${result}");
      UserModel user = UserModel(
          userId: result['creator'][0]['id'],
          lastName:result['creator'][0]['last_name'],
          firstName: result['creator'][0]['first_name'],
          avatarUrl: result['creator'][0]['avatar']
      );
      Post postModel = Post(
        zone: result['zone'],
        postId: result['id'],
        commentCount:RxInt(result['comment_count']),
        likeCount:RxInt(result ['like_count']) ,
        shareCount:RxInt(result ['share_count']),
        content: result['content'],
        publishedDate: result['humanize_date_creation'],
        imagesUrl: result['images'],
        user: user,
        liked: result['liked'],
        likeTapped: RxBool(result['liked']),
        isFollowing: RxBool(result['is_following']),
        commentList: result['comments'],
        sectors: result['sectors'],
        zonePostId: result['zone']['id'],
        zoneLevelId: result['zone']['level_id'],
        zoneParentId: result['zone']['parent_id']

      );
      loadingAPost.value = true;
      initializePostDetails(postModel);

    }
    catch (e) {
      loadingAPost.value = false;
      if(! Platform.environment.containsKey('FLUTTER_TEST')){
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }
    finally {

    }

  }

  commentPost(int postId, String comment)async{
    try{
      sendComment.value = true;
      var result= await communityRepository.commentPost(postId, comment);
      print("Result again : ${result}");
      UserModel user = UserModel(userId: result['creator'][0]['id'],
          lastName:result['creator'][0]['last_name'],
          firstName: result['creator'][0]['first_name'],
          avatarUrl: result['creator'][0]['avatar']
      );
      Post postModel = Post(
          zone: result['zone'],
          postId: result['id'],
          commentCount:RxInt(result ['comment_count']),
          likeCount:RxInt(result ['like_count']) ,
          shareCount:RxInt(result ['share_count']),
          content: result['content'],
          publishedDate: result['published_at'],
          imagesUrl: result['images'],
          user: user,
          liked: result['liked'],
          likeTapped: RxBool(result['liked']),
          commentList: result['comments']

      );
      sendComment.value = false;
      return postModel;

    }
    catch (e) {
      sendComment.value = false;
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
    finally {
      sendComment.value = false;
    }

  }

  sharePost(int postId, int index)async{
    try{
      copyLink.value = false;
      showDialog(context: Get.context!, builder: (context){
        return CommentLoadingWidget();
      },);
      await communityRepository.sharePost(postId);
      Navigator.of(Get.context!).pop();
      Share.share('https://www.residat.com/show-post/${postId}');

    }
    catch (e) {
      if(!shareMyPost.value) {
        allPosts.elementAt(index).shareCount.value = allPosts.elementAt(index).shareCount.value -1;
      }

      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));

    }
    finally {

    }

  }

  deletePost(int postId)async{
    print(postId);
    try{
      await communityRepository.deletePost(postId);
      Get.showSnackbar(Ui.SuccessSnackBar(message:  AppLocalizations.of(Get.context!).post_deleted_successful ));
      listAllPosts.clear();
      allPosts.clear();
      loadingPosts.value = true;
      listAllPosts = await getAllPosts(0);
      allPosts.value = listAllPosts;

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


  followUser(int userId, int index)async{
    try{

      await userRepository.followUser(userId);
     // Navigator.of(Get.context!).pop();
      //Get.showSnackbar(Ui.SuccessSnackBar(message: 'You are now following this user' ));

    }
    catch (e) {
      allPosts.elementAt(index).isFollowing.value = !allPosts.elementAt(index).isFollowing.value;
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));

    }
    finally {

    }

  }

  unfollowUser(int userId, int index)async{
    try{

      await userRepository.unfollowUser(userId);
      //Navigator.of(Get.context!).pop();
      //Get.showSnackbar(Ui.SuccessSnackBar(message: 'You have just unfollowed this user' ));

    }
    catch (e) {
      allPosts.elementAt(index).isFollowing.value = !allPosts.elementAt(index).isFollowing.value;
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));

    }
    finally {

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


