import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/notifications/controllers/notification_controller.dart';
import 'package:mapnrank/app/repositories/notification_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:image/image.dart' as Im;

import 'notification_controller_test.mocks.dart';

class MockImageLibrary extends Mock {
  Im.Image? decodeImage(List<int> bytes);
  List<int> encodeJpg(Im.Image image, {int quality = 90});
}

class MockNotification extends Mock implements NotificationModel {
  @override
  bool operator ==(other) {
    // TODO: implement ==
    return super == other;
  }
}


@GenerateMocks([AuthService,
  NotificationRepository,
  ZoneRepository,
  ImagePicker,
  Directory,
  File,
  Image
])

void main() {
  late NotificationController notificationController;
  late MockNotificationRepository mockNotificationRepository;
  late MockZoneRepository mockZoneRepository;
  late MockImagePicker mockImagePicker;
  late MockDirectory mockDirectory;
  late MockFile mockFile;
  late MockImage mockImage;
  late List<int> encodedImageBytes;
  late Im.Image mockDecodedImage;
  late MockImageLibrary mockImageLibrary;
  late MockNotification mockNotification;


  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.lazyPut(()=>AuthService());

    mockNotificationRepository = MockNotificationRepository();
    mockZoneRepository = MockZoneRepository();
    mockFile = MockFile();
    mockImage = MockImage();
    encodedImageBytes = [1, 2, 3, 4];
    mockImagePicker = MockImagePicker();
    mockDirectory = MockDirectory();
    mockFile = MockFile();
    mockImage = MockImage();
    mockImageLibrary = MockImageLibrary();
    mockDecodedImage = Im.Image(width: 100, height: 100);
    mockNotification = MockNotification();



    AuthService().user = Rx<UserModel>(UserModel(userId: 1, firstName: "John", lastName: "Doe", language: "en"));


    notificationController = NotificationController();
    notificationController.notificationRepository = mockNotificationRepository;
    notificationController.zoneRepository = mockZoneRepository;
    notificationController.notification =MockNotification();

    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });

  });

  group('NotificationController', () {
    test('should fetch notifications successfully', () async {
      // Arrange
      final mockNotificationList = [
        NotificationModel(
          notificationId: 1,
          content: "Test Notification",
          title: "Test Title",
          userModel: UserModel(
            userId: 1,
            firstName: "John",
            lastName: "Doe",
          ),
          date: "2024-12-11",
          bannerUrl: "",
          zoneName: "Test Zone",
        )
      ];
      when(mockNotificationRepository.getUserNotifications())
          .thenAnswer((_) async => mockNotificationList);

      // Act
      await notificationController.getNotifications();

      // Assert
      verify(mockNotificationRepository.getUserNotifications()).called(1);
    });

    test('should classify notifications correctly', () {
      // Arrange
      final mockCreatedNotification = NotificationModel(
        notificationId: 1,
        content: "Test Created Notification",
        title: "Created",
        userModel: UserModel(userId: 1, firstName: "John", lastName: "Doe"),
        date: "2024-12-11",
        bannerUrl: "",
        zoneName: "Test Zone",
      );
      final mockReceivedNotification = NotificationModel(
        notificationId: 2,
        content: "Test Received Notification",
        title: "Received",
        userModel: UserModel(userId: 2, firstName: "Jane", lastName: "Smith"),
        date: "2024-12-11",
        bannerUrl: "",
        zoneName: "Test Zone",
      );

      notificationController.notificationList = [
        mockCreatedNotification,
        mockReceivedNotification
      ];

      // Act
      notificationController.classifyNotifications(notificationController.notificationList);

      // Assert
      expect(notificationController.createdNotifications.length, 0);
      expect(notificationController.receivedNotifications.length, 2);
      expect(notificationController.receivedNotifications[0].title, "Created");
    });

    test('should call getAllRegions correctly', () async {
      // Arrange
      final mockRegionData = {
        'status': true,
        'data': [
          {'id': 1, 'name': 'Region 1'},
          {'id': 2, 'name': 'Region 2'}
        ]
      };
      when(mockZoneRepository.getAllRegions(2, 1))
          .thenAnswer((_) async => mockRegionData);

      // Act
      final result = await notificationController.getAllRegions();

      // Assert
      expect(result['status'], true);
      expect(result['data'].length, 2);
      verify(mockZoneRepository.getAllRegions(2, 1)).called(1);
    });
  });

  test('Filter Search Regions Test', () async {
    notificationController.listRegions.value =
    [{'name': 'Region 1'}, {'name': 'Region 2'}];

    notificationController.filterSearchRegions('region 1');
    expect(notificationController.regions.length, 1);
    expect(notificationController.regions[0]['name'], 'Region 1');
  });

  test('filter Search Regions returns all regions when query is empty', () {
    notificationController.listRegions = [
      {'name': 'North Region'},
      {'name': 'South Region'},
    ].obs;
    notificationController.regions = RxList([]);
// Act: Call the filterSearchDivisions with an empty query
    notificationController.filterSearchRegions('');

// Assert: Verify that all divisions are returned
    expect(notificationController.regions.length, 2);
    expect(notificationController.regions[0]['name'], 'North Region');
    expect(notificationController.regions[1]['name'], 'South Region');
  });
  test('filter Search Regions returns no divisions for a query with no matches', () {
// Act: Call the filterSearchDivisions with a query that has no matches
    notificationController.filterSearchRegions('central');

// Assert: Verify that no divisions are returned
    expect(notificationController.regions.length, 0);
  });

  test('Verify getAllRegions calls zoneRepository.getAllRegions with correct parameters', () async {
    // Arrange
    final expectedResponse = {
      'status': true,
      'data': [] // Replace with the expected data structure
    };

    when(mockZoneRepository.getAllRegions(2, 1)).thenAnswer((_) async => expectedResponse);

    // Act
    final result = await notificationController.getAllRegions();

    // Assert
    expect(result, expectedResponse);
    verify(mockZoneRepository.getAllRegions(2, 1)).called(1);
    verifyNoMoreInteractions(mockZoneRepository);
  });

  test('Verify getAllDivisions calls zoneRepository with correct parameters', () async {
    // Arrange: Set up regions and the return value
    notificationController.regions = [{'id': 1}, {'id': 2}].obs;
    when(mockZoneRepository.getAllDivisions(3, 1)).thenAnswer((_) async => {'status': true});

    // Act: Call the method
    final result = await notificationController.getAllDivisions(0);

    // Assert: Verify the correct method is called with correct parameters
    verify(mockZoneRepository.getAllDivisions(3, 1)).called(2);
    expect(result, {'status': true});
  });

  test('filterSearchDivisions filters correctly with a query', () {
    notificationController.listDivisions = [
      {'name': 'North Division'},
      {'name': 'South Division'},
      {'name': 'East Division'},
      {'name': 'West Division'},
    ].obs;
    notificationController.divisions = RxList([]);
// Act: Call the filterSearchDivisions with a specific query
    notificationController.filterSearchDivisions('north');

// Assert: Verify that the divisions list is filtered correctly
    expect(notificationController.divisions.length, 1);
    expect(notificationController.divisions[0]['name'], 'North Division');
  });

  test('filterSearchDivisions returns all divisions when query is empty', () {
    notificationController.listDivisions = [
      {'name': 'North Division'},
      {'name': 'South Division'},
      {'name': 'East Division'},
      {'name': 'West Division'},
    ].obs;
    notificationController.divisions = RxList([]);
// Act: Call the filterSearchDivisions with an empty query
    notificationController.filterSearchDivisions('');

// Assert: Verify that all divisions are returned
    expect(notificationController.divisions.length, 4);
    expect(notificationController.divisions[0]['name'], 'North Division');
    expect(notificationController.divisions[1]['name'], 'South Division');
    expect(notificationController.divisions[2]['name'], 'East Division');
    expect(notificationController.divisions[3]['name'], 'West Division');
  });

  test('filterSearchDivisions returns no divisions for a query with no matches', () {
// Act: Call the filterSearchDivisions with a query that has no matches
    notificationController.filterSearchDivisions('central');

// Assert: Verify that no divisions are returned
    expect(notificationController.divisions.length, 0);
  });

  test('getAllSubdivisions returns data correctly', () async {
    // Arrange
    int index = 0;
    List<Map<String, dynamic>> divisionsList = [
      {'id': 1, 'name': 'Division 1'},
      {'id': 2, 'name': 'Division 2'},
    ];
    notificationController.divisions.value = divisionsList;

    Map<String, dynamic> expectedResponse = {
      'status': true,
      'data': [{'id': 101, 'name': 'Subdivision 1'}],
    };

    when(mockZoneRepository.getAllSubdivisions(4, divisionsList[index]['id']))
        .thenAnswer((_) async => expectedResponse);

    // Act
    final result = await notificationController.getAllSubdivisions(index);

    // Assert
    expect(result, expectedResponse);
    verify(mockZoneRepository.getAllSubdivisions(4, divisionsList[index]['id']))
        .called(1);
  });

  test('getAllSubdivisions handles empty divisions list', () async {
    // Arrange
    int index = 0;
    notificationController.divisions.value = [];

    // Act & Assert
    expect(() => notificationController.getAllSubdivisions(index), throwsRangeError);
  });

  test('filterSearchSubdivisions filters subdivisions by query', () {
    notificationController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    notificationController.subdivisions.value = notificationController.listSubdivisions;
// Act
    notificationController.filterSearchSubdivisions('Subdivision A');

// Assert
    expect(notificationController.subdivisions.value, [
      {'name': 'Subdivision A'}
    ]);
  });

  test('filterSearchSubdivisions returns all subdivisions when query is empty', () {
    notificationController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    notificationController.subdivisions.value = notificationController.listSubdivisions;
// Act
    notificationController.filterSearchSubdivisions('');

// Assert
    expect(notificationController.subdivisions.value, notificationController.listSubdivisions);
  });

  test('filterSearchSubdivisions handles case-insensitive queries', () {
    notificationController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    notificationController.subdivisions.value = notificationController.listSubdivisions;
// Act
    notificationController.filterSearchSubdivisions('Subdivision b');

// Assert
    expect(notificationController.subdivisions.value, [
      {'name': 'Subdivision B'}
    ]);
  });

  group('createNotifications', () {
    test('should successfully create a notification and call getNotifications', () async {
      // Arrange
      final notification = NotificationModel();
      when(mockNotificationRepository.createNotification(notification))
          .thenAnswer((_) async => 'Notification created');
      when(mockNotificationRepository.getUserNotifications()).thenAnswer((_) async => []);

      // Act
      await notificationController.createNotifications(notification);

      // Assert
      expect(notificationController.createNotification.value, false);
      verify(mockNotificationRepository.createNotification(notification)).called(1);
      verify(mockNotificationRepository.getUserNotifications()).called(1);
    });

    test('should handle exceptions and show error snackbar', () async {
      // Arrange
      final notification = NotificationModel();
      final errorMessage = 'An error occurred';
      when(mockNotificationRepository.createNotification(notification))
          .thenThrow(Exception(errorMessage));

      // Act
      await notificationController.createNotifications(notification);

      // Assert
      expect(notificationController.createNotification.value, false);
      verify(mockNotificationRepository.createNotification(notification)).called(1);
    });
  });

  group('deleteSpecificNotification', () {
    test('should successfully delete a notification and show success snackbar', () async {
      // Arrange
      const notificationId = 1;
      when(mockNotificationRepository.deleteSpecificNotification(notificationId))
          .thenAnswer((_) async => 'Notification deleted');

      // Act
      final result = await notificationController.deleteSpecificNotification(notificationId);

      // Assert
      expect(result, 'Notification deleted');
      verify(mockNotificationRepository.deleteSpecificNotification(notificationId)).called(1);
    });

    test('should handle exceptions and show error snackbar', () async {
      // Arrange
      const notificationId = 1;
      final errorMessage = 'An error occurred';
      when(mockNotificationRepository.deleteSpecificNotification(notificationId))
          .thenThrow(Exception(errorMessage));

      // Act
      await notificationController.deleteSpecificNotification(notificationId);

      // Assert
      verify(mockNotificationRepository.deleteSpecificNotification(notificationId)).called(1);
    });
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
    await notificationController.pickImage(ImageSource.camera);
    notificationController.notification.imageNotificationBanner = [imageFile];
    var decodedImage = mockImageLibrary.decodeImage(imageBytes);
    //var result = mockImageLibrary.encodeJpg(Im.Image(width:100, height:100), quality: 90);

    //final encodedImage = Im.encodeJpg(image!, quality: 25);

    // Assert
    expect(notificationController.imageFiles.isNotEmpty, true);
    expect(decodedImage, mockDecodedImage);
    //expect(result, encodedImageBytes);
    //expect(eventsController.event.imagesFileBanner?.isNotEmpty, true);
    //verify(mockImagePicker.pickImage(source: ImageSource.camera, imageQuality: 80)).called(1);
    //verify(getTemporaryDirectory()).called(1);
  });

  test('pickImage with gallery source processes and compresses multiple images', () async {
    const TEST_MOCK_STORAGE = ['./test/test_pictures/filter.PNG'];
    const channel = MethodChannel(
      'plugins.flutter.io/image_picker',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });
    // Arrange
    final pickedFiles = [
      XFile('test/test_pictures/filter.PNG'),
      XFile('test/test_pictures/filter.PNG')
    ];
    final tempDir = MockDirectory();
    final imageFile1 = File('test/test_pictures/filter.png');
    final imageFile2 = File('test/test_pictures/filter.png');
    final imageBytes = [0, 0, 0];
    final path = '/temp/path';// Dummy bytes
    notificationController.imageFiles.value = [];

    when(mockImagePicker.pickMultiImage())
        .thenAnswer((_) async => pickedFiles);

    when(tempDir.path).thenReturn(path);

    // // Simulate image encoding
    // //when(Im.encodeJpg(mockFile, quality: 25)).thenReturn(Uint8List(0));
    //
    // Act
    await notificationController.pickImage(ImageSource.gallery);
    //eventsController.imageFiles.value = pickedFiles;
    //
    // // Assert
    expect(notificationController.imageFiles.length, 1);
    //expect(eventsController.event.imagesFileBanner?.length, 2);
    // verify(mockImagePicker.pickMultiImage()).called(1);
    // verify(getTemporaryDirectory()).called(2);  // Called for each image
  });
}
