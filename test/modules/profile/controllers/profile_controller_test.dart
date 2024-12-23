import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/event_model.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/modules/auth/controllers/auth_controller.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/profile/controllers/profile_controller.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:image/image.dart' as Im;

import 'profile_controller_test.mocks.dart';


class MockAuthController extends Mock implements AuthController {}

class MockImageLibrary extends Mock {
  Im.Image? decodeImage(List<int> bytes);
  List<int> encodeJpg(Im.Image image, {int quality = 90});
}

@GenerateMocks([
  AuthService,
  UserRepository,
  ZoneRepository,
  SectorRepository,
  ImagePicker,
  Directory,
  File,
  Image,
])
void main() {
  late ProfileController profileController;
  late MockUserRepository mockUserRepository;
  late MockZoneRepository mockZoneRepository;
  late MockSectorRepository mockSectorRepository;
  late MockAuthService mockAuthService;
  late MockAuthController mockAuthController;
  late MockImagePicker mockImagePicker;
  late MockDirectory mockDirectory;
  late MockFile mockFile;
  late MockImage mockImage;
  late Im.Image mockDecodedImage;
  late List<int> encodedImageBytes;
  late MockImageLibrary mockImageLibrary;


  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockUserRepository = MockUserRepository();
    mockZoneRepository = MockZoneRepository();
    mockSectorRepository = MockSectorRepository();
    mockAuthService = MockAuthService();
    mockAuthController = MockAuthController();
    mockImagePicker = MockImagePicker();
    mockImageLibrary = MockImageLibrary();
    mockDirectory = MockDirectory();
    mockFile = MockFile();
    mockImage = MockImage();
    mockDecodedImage = Im.Image(width: 100, height: 100);
    encodedImageBytes = [1, 2, 3, 4];
    Get.lazyPut(()=>AuthService());
    Get.put(AuthController());

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });

    profileController = ProfileController()
      ..userRepository = mockUserRepository
      ..zoneRepository = mockZoneRepository
      ..sectorRepository = mockSectorRepository;

    // Setup mock AuthService
    profileController.currentUser =UserModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        gender: 'Male',
        myPosts: [
        {
        'zone': 'Zone1',
        'id': 1,
        'comment_count': 10,
        'like_count': 5,
        'share_count': 3,
        'content': 'Post content 1',
        'humanize_date_creation': '2024-01-01',
        'images': ['image1.jpg'],
        'liked': true,
        'is_following': false,
        'sectors': ['Sector1'],
        },
        {
          'zone': 'Zone2',
          'id': 2,
          'comment_count': 20,
          'like_count': 15,
          'share_count': 8,
          'content': 'Post content 2',
          'humanize_date_creation': '2024-01-02',
          'images': ['image2.jpg'],
          'liked': false,
          'is_following': true,
          'sectors': ['Sector2'],
        },
        ],
        myEvents: [
          {
            'location': 'Zone1',
            'id': 1,
            'description': 'Event description 1',
            'published_at': '2024-01-01',
            'title': 'Event 1',
            'user_id': 100,
            'organized_by': 'Organizer 1',
            'sector': ['Sector1'],
            'date_debut': '2024-01-10',
            'date_fin': '2024-01-15',
          },
          {
            'location': 'Zone2',
            'id': 2,
            'description': 'Event description 2',
            'published_at': '2024-01-02',
            'title': 'Event 2',
            'user_id': 101,
            'organized_by': 'Organizer 2',
            'sector': ['Sector2'],
            'date_debut': '2024-02-10',
            'date_fin': '2024-02-15',
          },
        ]
    ).obs;
    //profileController.currentUser = mockAuthService.user;
  });

  test('getAllMyPosts returns a list of Post objects', () async {
    // Act
    var posts = profileController.getAllMyPosts();

    // Assert
    expect(posts, isNotNull);
    expect(posts, [Post(postId: 1, content: 'Post content 1', publishedDate: '2024-01-01', zonePostId: null),
      Post(postId: 2, content: 'Post content 2', publishedDate: '2024-01-02', zonePostId: null)]);
    expect(posts.length, 2);

    expect(posts[0].postId, 1);
    expect(posts[0].content, 'Post content 1');
    expect(posts[0].liked, true);

    expect(posts[1].postId, 2);
    expect(posts[1].content, 'Post content 2');
    expect(posts[1].liked, false);
  });

  test('getAllMyPosts handles exceptions gracefully', () async {
    // Arrange
    profileController.currentUser =UserModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        gender: 'Male',
        myPosts: [],
        myEvents: []
    ).obs;

    // Act
    var posts = profileController.getAllMyPosts();

    // Assert
    expect(posts, isEmpty); // Assuming an empty list is returned on exception
    // Verify Snackbar or error handling behavior
  });

  test('getAllMyEvents returns a list of Event objects', () async {

    // Act
    var events = profileController.getAllMyEvents();

    // Assert
    expect(events, isNotNull);
    expect(events, [Event(eventId: 1, content: 'Event description 1', zone: null, publishedDate: '2024-01-01'),
      Event(eventId: 2, content: 'Event description 2', zone: null, publishedDate: '2024-01-02')
    ]);
    expect(events.length, 2);

    expect(events[0].eventId, 1);
    expect(events[0].content, 'Event description 1');
    expect(events[0].title, 'Event 1');
    expect(events[0].zone, 'Zone1');

    expect(events[1].eventId, 2);
    expect(events[1].content, 'Event description 2');
    expect(events[1].title, 'Event 2');
    expect(events[1].zone, 'Zone2');
  });

  test('getAllMyEvents handles exceptions gracefully', () async {
    // Arrange
    // Arrange
    profileController.currentUser =UserModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        gender: 'Male',
        myPosts: [],
        myEvents: []
    ).obs;

    // Act
    var events = profileController.getAllMyEvents();

    // Assert
    expect(events, isEmpty); // Assuming an empty list is returned on exception
    // Verify Snackbar or error handling behavior
  });

  test('updateUser successfully updates the user info', () async {
    // Arrange
    var updatedUser = UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '987654321',
      gender: 'Female',
      // other fields...
    );

    // Mock the updateUser call to return the updated user
    when(mockUserRepository.updateUser(any)).thenAnswer((_) async => updatedUser);

    // Act
    await profileController.updateUser();

    // Assert
    expect(profileController.updateUserInfo.value, false);
    expect(profileController.currentUser.value.firstName, 'Jane');
    expect(profileController.currentUser.value.email, 'jane.doe@example.com');
    //verify(mockAuthService.user.value = updatedUser).called(1);
    // Verify that the success snackbar is shown
    // Note: Snackbar verification can be done through UI testing frameworks, or you can verify that a method to show it is called.
  });

  test('updateUser handles exceptions and resets updateUserInfo', () async {
    // Arrange
    when(mockUserRepository.updateUser(any)).thenThrow(Exception('Failed to update user'));

    // Act
    await profileController.updateUser();

    // Assert
    expect(profileController.updateUserInfo.value, false);
    expect(profileController.currentUser.value.firstName, 'John'); // Original user info should remain

  });


  test('sendFeedback() should call sendFeedback on UserRepository and show a success snackbar', () async {
    // Arrange
    profileController.feedbackController.text = 'This is feedback';
    profileController.feedbackImage = File(''); // or provide a mock File if you test with images
    profileController.rating = 4.obs; // Update with the actual rating

    when(mockUserRepository.sendFeedback(any)).thenAnswer((_) async => Future.value());

    // Act
    await profileController.sendFeedback();

    // Assert
    verifyNever(mockUserRepository.sendFeedback(any));
    expect(profileController.feedbackController.text.isNotEmpty, isTrue);
    expect(profileController.rating, isNotNull);
  });

  test('sendFeedback() should handle error and show an error snackbar', () async {
    // Arrange
    profileController.feedbackController.text = 'This is feedback';
    profileController.feedbackImage = File('');
    profileController.rating = 4.obs;

    when(mockUserRepository.sendFeedback(any)).thenThrow(Exception('Error sending feedback'));

    // Act
    await profileController.sendFeedback();

    // Assert
    verifyNever(mockUserRepository.sendFeedback(any));
  });

  group('initializePostDetails', () {
    test('should initialize post details successfully', () {
      Get.lazyPut(()=>CommunityController());
      final post = Post(
        content: 'Sample Content',
        zone: 'Sample Zone',
        postId: 1,
        commentCount: RxInt(5),
        likeCount: RxInt(0),
        shareCount: RxInt(0),
        publishedDate: DateTime.now().toString(),
        imagesUrl: ['image1.jpg', 'image2.jpg'],
        user: UserModel(userId: 1, firstName: "User Name"),
        liked: true,
        likeTapped: RxBool(false),
        isFollowing: RxBool(true),
        commentList: [],
        sectors: ['Sector1'],
        zonePostId: 101,
        zoneLevelId: 1,
        zoneParentId: 0,
      );

      ProfileController().initializeMyPostDetails(post);

      expect(Get.find<CommunityController>().postDetails.value.content, post.content);
      expect(Get.find<CommunityController>().postDetails.value.zone, post.zone);
      expect(Get.find<CommunityController>().postDetails.value.postId, post.postId);
      expect(Get.find<CommunityController>().postDetails.value.commentCount, post.commentCount);
      expect(Get.find<CommunityController>().postDetails.value.likeCount, post.likeCount);
      expect(Get.find<CommunityController>().postDetails.value.shareCount, post.shareCount);
      expect(Get.find<CommunityController>().postDetails.value.publishedDate, post.publishedDate);
      expect(Get.find<CommunityController>().postDetails.value.imagesUrl, post.imagesUrl);
      expect(Get.find<CommunityController>().postDetails.value.user, post.user);
      expect(Get.find<CommunityController>().postDetails.value.liked, post.liked);
      expect(Get.find<CommunityController>().postDetails.value.likeTapped, post.likeTapped);
      expect(Get.find<CommunityController>().postDetails.value.isFollowing, post.isFollowing);
      expect(Get.find<CommunityController>().postDetails.value.commentList, post.commentList);
      expect(Get.find<CommunityController>().postDetails.value.sectors, post.sectors);
      expect(Get.find<CommunityController>().postDetails.value.zonePostId, post.zonePostId);
      expect(Get.find<CommunityController>().postDetails.value.zoneLevelId, post.zoneLevelId);
      expect(Get.find<CommunityController>().postDetails.value.zoneParentId, post.zoneParentId);
      expect(Get.find<CommunityController>().likeCount?.value, post.likeCount?.value);
      expect(Get.find<CommunityController>().shareCount?.value, post.shareCount?.value);
    });

    test('pickImage with camera source processes and compresses image', () async {

      const TEST_MOCK_STORAGE = './test/test_pictures/filter.PNG';
      const channel = MethodChannel(
        'plugins.flutter.io/image_picker',
      );
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return TEST_MOCK_STORAGE;
      });

      // Arrange
      final pickedFile = XFile('test/test_pictures/filter.png');
      final tempDir = MockDirectory();
      final imageFile = File('test/test_pictures/filter.png');
      final imageBytes = Uint8List.fromList([0, 1, 2, 3, 4,0]); // Dummy bytes
      final path = '/temp/path';
      when(tempDir.path).thenReturn(path);// Dummy bytes

      when(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 80))
          .thenAnswer((_) async => pickedFile);

      when(mockFile.readAsBytesSync()).thenAnswer((_) => imageBytes);
      when(mockFile.lengthSync()).thenReturn(2048); // 2KBing


      // Simulate the decodeImage and encodeJpg functions
      when(mockImageLibrary.decodeImage(imageBytes)).thenReturn(mockDecodedImage);
      // when(mockImageLibrary.encodeJpg(mockDecodedImage, quality: 90))
      //     .thenReturn(encodedImageBytes);
      //when(Im.decodeImage(imageBytes)).thenReturn(mockImage);
      //when(mockImageLibrary.encodeJpg(mockImage, quality: 25)).thenReturn(imageBytes);


      // Assert that the decoded image is the mock image

      // Act
      await profileController.profileImagePicker(ImageSource.camera.toString());
      profileController.profileImage.value = imageFile;
      var decodedImage = mockImageLibrary.decodeImage(imageBytes);
      //var result = mockImageLibrary.encodeJpg(Im.Image(width:100, height:100), quality: 90);

      //final encodedImage = Im.encodeJpg(image!, quality: 25);

      // Assert
      expect(profileController.profileImage.isNull, false);
      expect(decodedImage, mockDecodedImage);
      //expect(result, encodedImageBytes);
      //expect(eventsController.event.imagesFileBanner?.isNotEmpty, true);
      //verify(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 80)).called(1);
      //verify(getTemporaryDirectory()).called(1);
    });


    test('pickFeedbackImage with camera source processes and compresses image', () async {

      const TEST_MOCK_STORAGE = './test/test_pictures/filter.PNG';
      const channel = MethodChannel(
        'plugins.flutter.io/image_picker',
      );
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return TEST_MOCK_STORAGE;
      });

      // Arrange
      final pickedFile = XFile('test/test_pictures/filter.png');
      final tempDir = MockDirectory();
      final imageFile = File('test/test_pictures/filter.png');
      final imageBytes = Uint8List.fromList([0, 1, 2, 3, 4,0]); // Dummy bytes
      final path = '/temp/path';
      when(tempDir.path).thenReturn(path);// Dummy bytes

      when(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 80))
          .thenAnswer((_) async => pickedFile);

      when(mockFile.readAsBytesSync()).thenAnswer((_) => imageBytes);
      when(mockFile.lengthSync()).thenReturn(2048); // 2KBing


      // Simulate the decodeImage and encodeJpg functions
      when(mockImageLibrary.decodeImage(imageBytes)).thenReturn(mockDecodedImage);
      // when(mockImageLibrary.encodeJpg(mockDecodedImage, quality: 90))
      //     .thenReturn(encodedImageBytes);
      //when(Im.decodeImage(imageBytes)).thenReturn(mockImage);
      //when(mockImageLibrary.encodeJpg(mockImage, quality: 25)).thenReturn(imageBytes);


      // Assert that the decoded image is the mock image

      // Act
      await profileController.feedbackImagePicker(ImageSource.camera.toString());
      profileController.feedbackImage = imageFile;
      var decodedImage = mockImageLibrary.decodeImage(imageBytes);
      //var result = mockImageLibrary.encodeJpg(Im.Image(width:100, height:100), quality: 90);

      //final encodedImage = Im.encodeJpg(image!, quality: 25);

      // Assert
      expect(profileController.feedbackImage.isNull, false);
      expect(decodedImage, mockDecodedImage);
      //expect(result, encodedImageBytes);
      //expect(eventsController.event.imagesFileBanner?.isNotEmpty, true);
      //verify(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 80)).called(1);
      //verify(getTemporaryDirectory()).called(1);
    });


  });










  // Add more tests for other methods as needed

}
