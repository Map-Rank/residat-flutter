import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/other_user_profile/controllers/other_user_profile_controller.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

import 'other_user_profile_controller_test.mocks.dart';



@GenerateMocks([UserRepository])
void main() {
  late OtherUserProfileController otherUserProfileController;
  late MockUserRepository mockUserRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockUserRepository = MockUserRepository();
    otherUserProfileController = OtherUserProfileController()
      ..userRepository = mockUserRepository;

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });



    // Setup mock AuthService
    otherUserProfileController.currentUser =UserModel(
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
  });

  test('getAllMyPosts returns a list of Post objects', () async {
    // Act
    var posts = otherUserProfileController.getAllMyPosts();

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
    otherUserProfileController.currentUser =UserModel(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '1234567890',
        gender: 'Male',
        myPosts: [],
        myEvents: []
    ).obs;

    // Act
    var posts = otherUserProfileController.getAllMyPosts();

    // Assert
    expect(posts, isEmpty); // Assuming an empty list is returned on exception
    // Verify Snackbar or error handling behavior
  });

  test('getUser() should update currentUser and AuthService user on success', () async {
    Get.lazyPut(()=>AuthService());
    // Arrange: Mock the getUser method to return a user object
    var mockUser = UserModel(
      myPosts: ['post1', 'post2'],
      myEvents: ['event1', 'event2'],
    );
    when(mockUserRepository.getAnotherUserProfile(1)).thenAnswer((_) async => mockUser);

    // Act: Call the method
    await otherUserProfileController.getAnotherUserProfile(1);

    // Assert: Verify that getUser was called
    verify(mockUserRepository.getAnotherUserProfile(1)).called(1);

    // Verify that currentUser and AuthService user are updated
    expect(otherUserProfileController.currentUser.value, mockUser);
    expect(otherUserProfileController.currentUser.value.myPosts, ['post1', 'post2']);
    expect(otherUserProfileController.currentUser.value.myEvents, ['event1', 'event2']);
    expect(Get.find<AuthService>().user.value, mockUser);
  });

  test('getUser() should not show an error snackbar in test environment', () async {
    // Arrange: Mock the getUser method to throw an exception
    when(mockUserRepository.getAnotherUserProfile(1)).thenThrow(Exception('Failed to get user'));

    // Act: Call the method
    await otherUserProfileController.getAnotherUserProfile(1);

    // Assert: Verify that getUser was called
    verify(mockUserRepository.getAnotherUserProfile(1)).called(1);

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

      OtherUserProfileController().initializePostDetails(post);

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


  });

}
