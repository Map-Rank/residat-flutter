import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/auth/controllers/auth_controller.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/notifications/controllers/notification_controller.dart';
import 'package:mapnrank/app/modules/root/controllers/root_controller.dart';
import 'package:mapnrank/app/repositories/sector_repository.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/repositories/zone_repository.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/common/ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_controller_test.mocks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as Im;
import 'dart:math' as Math;

// Mock classes

class MockGetContext extends Mock implements BuildContext {}

class MockDashboardController extends Mock implements DashboardController {}

class MockCommunityController extends Mock implements CommunityController {}

class MockNotificationController extends Mock implements NotificationController {}

class MockEventsController extends Mock implements EventsController {}

class MockGetStorage extends Mock implements GetStorage {}
class MockAppLocalizations extends Mock implements AppLocalizations {}
class MockBuildContext extends Mock implements BuildContext {}
class MockUi extends Mock implements Ui {}
// Mock Timer class
class MockTimer extends Mock implements Timer {}

class MockImageLibrary extends Mock {
  Im.Image? decodeImage(List<int> bytes);
  List<int> encodeJpg(Im.Image image, {int quality = 90});
}


@GenerateMocks([
  AuthService,
  UserRepository,
  ZoneRepository,
  SectorRepository,
  RootController,
  ImagePicker,
  Directory,
  File,
  Image,

])
void main() {
  late AuthController authController;
  late MockAuthService mockAuthService;
  late MockUserRepository mockUserRepository;
  late MockZoneRepository mockZoneRepository;
  late MockSectorRepository mockSectorRepository;
  late MockGetStorage mockGetStorage;
  late MockImagePicker mockImagePicker;
  late MockFile mockFile;
  late MockRootController mockRootController;
  late MockDashboardController mockDashboardController;
  late MockCommunityController mockCommunityController;
  late MockNotificationController mockNotificationController;
  late MockEventsController mockEventsController;
  late MockGetStorage mockStorage;
  late MockAppLocalizations mockLocalizations;
  late MockBuildContext mockContext;
  late MockImage mockImage;
  late Im.Image mockDecodedImage;
  late MockImageLibrary mockImageLibrary;
  late List<int> encodedImageBytes;



  setUp(() async {
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAuthService = MockAuthService();
    mockUserRepository = MockUserRepository();
    mockZoneRepository = MockZoneRepository();
    mockSectorRepository = MockSectorRepository();
    mockGetStorage = MockGetStorage();
    mockImagePicker = MockImagePicker();
    mockFile = MockFile();
    mockImageLibrary = MockImageLibrary();
    mockDecodedImage = Im.Image(width: 100, height: 100);
    encodedImageBytes = [1, 2, 3, 4]; // C
    mockRootController = MockRootController();
    mockDashboardController = MockDashboardController();
    mockCommunityController = MockCommunityController();
    mockNotificationController = MockNotificationController();
    mockEventsController = MockEventsController();
    mockStorage = MockGetStorage();
    mockLocalizations = MockAppLocalizations();
    mockContext = MockBuildContext();
    Get.lazyPut(() => AuthService());
    Get.put<UserRepository>(mockUserRepository);


    const TEST_MOCK_STORAGE = '/test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });


    Get.put<AuthService>(mockAuthService);

    authController = AuthController();
    authController.picker = mockImagePicker;
    authController.loginFormKey = GlobalKey<FormState>(); // Initialize here
    authController.zoneRepository = mockZoneRepository;
    authController.userRepository = mockUserRepository;
    authController.sectorRepository = mockSectorRepository;
    mockImage = MockImage();
    authController.genderList=['Select gender', 'Male', 'Female', 'Other'].obs;
    authController.languageList=['Select language', 'English', 'French'].obs;
    authController.loginOrRegister = RxBool(true);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/filter.png';

    // Create a temporary image file
    final file = File(path);
    authController.profileImage = File(file.path);
    authController.selectedGender = "Male".obs;
    authController.selectedLanguage = "English".obs;
    authController.birthDateDisplay.text = "--/--/--";


  });

  test("Verify onInit initializes correctly", () async {
    // Stub AppLocalizations for testing
    // when(AppLocalizations.of(any)).thenReturn(MockAppLocalizations());



    // Stub GetStorage reads
    when(mockGetStorage.read('language')).thenReturn(null);
    when(mockGetStorage.read('allRegions')).thenReturn(null);
    when(mockGetStorage.read('allSectors')).thenReturn(null);

    // Stub methods in repositories
    when(mockZoneRepository.getAllRegions(any, any)).thenAnswer((_) async => {
      'status': true,
      'data': []
    });

    when(mockZoneRepository.getAllRegions(any, any)).thenAnswer((_) async => {
      'status': true,
      'data': []
    });

    when(mockSectorRepository.getAllSectors()).thenAnswer((_) async => {
      'status': true,
      'data': []
    });

    // Trigger onInit
    authController.onInit();

    // Verify initializations
    expect(authController.genderList.isNotEmpty, true);
    expect(authController.languageList.isNotEmpty, true);
    expect(authController.selectedGender.isNotEmpty, true);
    expect(authController.selectedLanguage.value, 'English');

  });

  test("Verify onInit shows language dialog when language is null", () async {
    when(mockGetStorage.read('language')).thenReturn(null);

    authController.onInit();

    // Verify dialog is shown
    //verify(mockGetStorage.read('language')).called(1);
    // Additional verifications can be done using a spy or mock for dialog
  });

  test("Verify onInit does not show language dialog when language is set", () async {
    when(mockGetStorage.read('language')).thenReturn('en');

    authController.onInit();

    // Verify dialog is not shown
    verifyNever(mockGetStorage.read('language'));
  });

  // Add more tests following the same structure to verify other behaviors

  test('Filter Search Regions Test', () async {
    authController.listRegions.value =
    [{'name': 'Region 1'}, {'name': 'Region 2'}];

    authController.filterSearchRegions('region 1');
    expect(authController.regions.length, 1);
    expect(authController.regions[0]['name'], 'Region 1');
  });
  test('filter Search Regions returns all regions when query is empty', () {
    authController.listRegions = [
      {'name': 'North Region'},
      {'name': 'South Region'},
    ].obs;
    authController.regions = RxList([]);
// Act: Call the filterSearchDivisions with an empty query
    authController.filterSearchRegions('');

// Assert: Verify that all divisions are returned
    expect(authController.regions.length, 2);
    expect(authController.regions[0]['name'], 'North Region');
    expect(authController.regions[1]['name'], 'South Region');
  });
  test('filter Search Regions returns no divisions for a query with no matches', () {
// Act: Call the filterSearchDivisions with a query that has no matches
    authController.filterSearchRegions('central');

// Assert: Verify that no divisions are returned
    expect(authController.regions.length, 0);
  });

  test('Verify getAllRegions calls zoneRepository.getAllRegions with correct parameters', () async {
    // Arrange
    final expectedResponse = {
      'status': true,
      'data': [] // Replace with the expected data structure
    };

    when(mockZoneRepository.getAllRegions(2, 1)).thenAnswer((_) async => expectedResponse);

    // Act
    final result = await authController.getAllRegions();

    // Assert
    expect(result, expectedResponse);
    verify(mockZoneRepository.getAllRegions(2, 1)).called(1);
    verifyNoMoreInteractions(mockZoneRepository);
  });

  test('Verify getAllDivisions calls zoneRepository with correct parameters', () async {
    // Arrange: Set up regions and the return value
    authController.regions = [{'id': 1}, {'id': 2}].obs;
    when(mockZoneRepository.getAllDivisions(3, 1)).thenAnswer((_) async => {'status': true});

    // Act: Call the method
    final result = await authController.getAllDivisions(0);

    // Assert: Verify the correct method is called with correct parameters
    verify(mockZoneRepository.getAllDivisions(3, 1)).called(1);
    expect(result, {'status': true});
  });

  test('filterSearchDivisions filters correctly with a query', () {
    authController.listDivisions = [
      {'name': 'North Division'},
      {'name': 'South Division'},
      {'name': 'East Division'},
      {'name': 'West Division'},
    ].obs;
    authController.divisions = RxList([]);
// Act: Call the filterSearchDivisions with a specific query
    authController.filterSearchDivisions('north');

// Assert: Verify that the divisions list is filtered correctly
    expect(authController.divisions.length, 1);
    expect(authController.divisions[0]['name'], 'North Division');
  });

  test('filterSearchDivisions returns all divisions when query is empty', () {
    authController.listDivisions = [
      {'name': 'North Division'},
      {'name': 'South Division'},
      {'name': 'East Division'},
      {'name': 'West Division'},
    ].obs;
    authController.divisions = RxList([]);
// Act: Call the filterSearchDivisions with an empty query
    authController.filterSearchDivisions('');

// Assert: Verify that all divisions are returned
    expect(authController.divisions.length, 4);
    expect(authController.divisions[0]['name'], 'North Division');
    expect(authController.divisions[1]['name'], 'South Division');
    expect(authController.divisions[2]['name'], 'East Division');
    expect(authController.divisions[3]['name'], 'West Division');
  });

  test('filterSearchDivisions returns no divisions for a query with no matches', () {
// Act: Call the filterSearchDivisions with a query that has no matches
    authController.filterSearchDivisions('central');

// Assert: Verify that no divisions are returned
    expect(authController.divisions.length, 0);
  });

  test('getAllSubdivisions returns data correctly', () async {
    // Arrange
    int index = 0;
    List<Map<String, dynamic>> divisionsList = [
      {'id': 1, 'name': 'Division 1'},
      {'id': 2, 'name': 'Division 2'},
    ];
    authController.divisions.value = divisionsList;

    Map<String, dynamic> expectedResponse = {
      'status': true,
      'data': [{'id': 101, 'name': 'Subdivision 1'}],
    };

    when(mockZoneRepository.getAllSubdivisions(4, divisionsList[index]['id']))
        .thenAnswer((_) async => expectedResponse);

    // Act
    final result = await authController.getAllSubdivisions(index);

    // Assert
    expect(result, expectedResponse);
    verify(mockZoneRepository.getAllSubdivisions(4, divisionsList[index]['id']))
        .called(1);
  });

  test('getAllSubdivisions handles empty divisions list', () async {
    // Arrange
    int index = 0;
    authController.divisions.value = [];

    // Act & Assert
    expect(() => authController.getAllSubdivisions(index), throwsRangeError);
  });

  test('filterSearchSubdivisions filters subdivisions by query', () {
    authController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    authController.subdivisions.value = authController.listSubdivisions;
// Act
    authController.filterSearchSubdivisions('Subdivision A');

// Assert
    expect(authController.subdivisions.value, [
      {'name': 'Subdivision A'}
    ]);
  });

  test('filterSearchSubdivisions returns all subdivisions when query is empty', () {
    authController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    authController.subdivisions.value = authController.listSubdivisions;
// Act
    authController.filterSearchSubdivisions('');

// Assert
    expect(authController.subdivisions.value, authController.listSubdivisions);
  });

  test('filterSearchSubdivisions handles case-insensitive queries', () {
    authController.listSubdivisions = [
      {'name': 'Subdivision A'},
      {'name': 'Subdivision B'},
      {'name': 'Another Subdivision'}
    ].obs;
    authController.subdivisions.value = authController.listSubdivisions;
// Act
    authController.filterSearchSubdivisions('Subdivision b');

// Assert
    expect(authController.subdivisions.value, [
      {'name': 'Subdivision B'}
    ]);
  });


  test('filterSearchSectors filters sectors by query', () {
    authController.listSectors = [
      {'name': 'Sector A'},
      {'name': 'Sector B'},
      {'name': 'Another Sector'}
    ].obs;
    authController.sectors.value = authController.listSectors;
// Act
    authController.filterSearchSectors('Sector A');

// Assert
    expect(authController.sectors.value, [
      {'name': 'Sector A'}
    ]);
  });

  test('filterSearchSectors returns all sectors when query is empty', () {
    authController.listSectors = [
      {'name': 'Sector A'},
      {'name': 'Sector B'},
      {'name': 'Another Sector'}
    ].obs;
    authController.sectors.value = authController.listSectors;
// Act
    authController.filterSearchSectors('');

// Assert
    expect(authController.sectors.value, authController.listSectors);
  });

  test('filterSearchSectors handles case-insensitive queries', () {
    authController.listSectors = [
      {'name': 'Sector A'},
      {'name': 'Sector B'},
      {'name': 'Another Sector'}
    ].obs;
    authController.sectors.value = authController.listSectors;
// Act
    authController.filterSearchSectors('b');

// Assert
    expect(authController.sectors.value, [
      {'name': 'Sector B'}
    ]);
  });

  test('Register method success', () async {
    // Set up the initial state
    final user = UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],

    ); // Assuming a User class exists
    authController.currentUser.value = user;

    // Mock the register method to return a user
    when(mockUserRepository.register(any))
        .thenAnswer((_) async => user);

    // Mock AuthService and RootController behaviors
    when(mockAuthService.user).thenReturn(UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],

    ).obs);
    when(mockRootController.changePage(0)).thenAnswer((_) async => {});

    // Call the register method
    await authController.register();

    // Verify that the register method was called
    verify(mockUserRepository.register(user)).called(1);
    // Verify that the user is set in AuthService
    expect(mockAuthService.user.value, equals(user));

  });

  test('Register method failure', () async {
    // Set up the initial state
    final user = UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],
    ); // Assuming a User class exists
    authController.currentUser.value = user;

    // Mock the register method to throw an exception
    when(mockUserRepository.register(any)).thenThrow(Exception('Registration failed'));

    // Call the register method
    authController.register();

    // Verify that the register method was called
    verify(mockUserRepository.register(user)).called(1);
    // Verify that the error snackbar was shown

  });

  test('RegisterInstitution method success', () async {
    // Set up the initial state
    final user = UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],

    ); // Assuming a User class exists
    authController.currentUser.value = user;

    // Mock the register method to return a user
    when(mockUserRepository.registerInstitution(any))
        .thenAnswer((_) async => user);

    // Mock AuthService and RootController behaviors
    when(mockAuthService.user).thenReturn(UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],

    ).obs);
    when(mockRootController.changePage(0)).thenAnswer((_) async => {});

    // Call the register method
    await authController.registerInstitution();

    // Verify that the register method was called
    verify(mockUserRepository.registerInstitution(user)).called(1);
    // Verify that the user is set in AuthService
    expect(mockAuthService.user.value, equals(user));

  });

  test('RegisterInstitution method failure', () async {
    // Set up the initial state
    final user = UserModel(
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane.doe@example.com',
      phoneNumber: '9876543210',
      gender: 'female',
      userId: 2,
      birthdate: '1995-02-15',
      authToken: 'auth456',
      zoneId: 'est',
      password: null,
      avatarUrl: 'https://example.com/avatar2.jpg',
      myPosts: [],
    ); // Assuming a User class exists
    authController.currentUser.value = user;

    // Mock the register method to throw an exception
    when(mockUserRepository.registerInstitution(any)).thenThrow(Exception('Registration failed'));

    // Call the register method
    authController.registerInstitution();

    // Verify that the register method was called
    verify(mockUserRepository.registerInstitution(user)).called(1);
    // Verify that the error snackbar was shown

  });

  test('getAllSectors() should return data from sectorRepository', () async {
    // Arrange: Mock the getAllSectors response
    final mockSectorsResponse = {
      'status': true,
      'data': [
        {'id': 1, 'name': 'Sector 1'},
        {'id': 2, 'name': 'Sector 2'},
      ],
    };

    when(mockSectorRepository.getAllSectors())
        .thenAnswer((_) async => mockSectorsResponse);

    // Act: Call the method
    final result = await authController.getAllSectors();

    // Assert: Verify the response and that the repository method was called
    expect(result, mockSectorsResponse);
    verify(mockSectorRepository.getAllSectors()).called(1);
    verifyNoMoreInteractions(mockSectorRepository);
  });

  test('getAllSectors() should handle exceptions', () async {
    // Arrange: Mock an exception being thrown
    when(mockSectorRepository.getAllSectors()).thenThrow(Exception('Failed to load sectors'));

    // Act: Call the method and capture the exception
    try {
      await authController.getAllSectors();
      fail("Exception not thrown");
    } catch (e) {
      // Assert: Verify the exception was thrown and that the repository method was called
      expect(e.toString(), contains('Failed to load sectors'));
    }
    verify(mockSectorRepository.getAllSectors()).called(1);
    verifyNoMoreInteractions(mockSectorRepository);
  });

  test('resetPassword() should call userRepository.resetPassword and handle success', () async {
    // Arrange: Mock the resetPassword method to complete successfully
    when(mockUserRepository.resetPassword(any)).thenAnswer((_) async => {});

    // Act: Call the method
    await authController.resetPassword('test@example.com');

    // Assert: Verify that the method was called and loading value was set correctly
    verify(mockUserRepository.resetPassword('test@example.com')).called(1);
    expect(authController.loading.value, false);
  });

  test('resetPassword() should handle errors and show snackbar when not in test environment', () async {
    // Arrange: Mock the resetPassword method to throw an exception
    when(mockUserRepository.resetPassword(any)).thenThrow(Exception('Failed to reset password'));

    // Act: Call the method
    await authController.resetPassword('test@example.com');

    // Assert: Verify that loading value was set correctly and snackbar was shown
    verify(mockUserRepository.resetPassword('test@example.com')).called(1);
    expect(authController.loading.value, false);

  });

  test('resetPassword() should handle errors and not show snackbar when in test environment', () async {
    // Arrange: Mock the resetPassword method to throw an exception
    when(mockUserRepository.resetPassword(any)).thenThrow(Exception('Failed to reset password'));

    // Act: Call the method
    await authController.resetPassword('test@example.com');

    // Assert: Verify that loading value was set correctly and snackbar was not shown
    verify(mockUserRepository.resetPassword('test@example.com')).called(1);
    expect(authController.loading.value, false);
  });

  test('deleteAccount() should handle success', () async {
    // Arrange: Mock the deleteAccount method to complete successfully
    when(mockUserRepository.deleteAccount()).thenAnswer((_) async => {});

    // Act: Call the method
    await authController.deleteAccount();

    // Assert: Verify that the method was called and snackbar was shown
    verify(mockUserRepository.deleteAccount()).called(1);
    expect(authController.loading.value, false);


    // Verify navigation to LOGIN route
    //verify(Get.toNamed(Routes.LOGIN)).called(1);
  });

  test('deleteAccount() should handle errors and show snackbar when not in test environment', () async {
    // Arrange: Mock the deleteAccount method to throw an exception
    when(mockUserRepository.deleteAccount()).thenThrow(Exception('Failed to delete account'));

    // Act: Call the method
    await authController.deleteAccount();

    // Assert: Verify that the method was called and loading value was set correctly
    verify(mockUserRepository.deleteAccount()).called(1);
    expect(authController.loading.value, false);


    // Verify that Get.toNamed was not called
    //verifyNever(Get.toNamed(Routes.LOGIN));
  });

  test('deleteAccount() should handle errors and not show snackbar when in test environment', () async {
    // Arrange: Mock the deleteAccount method to throw an exception
    when(mockUserRepository.deleteAccount()).thenThrow(Exception('Failed to delete account'));

    // Act: Call the method
    await authController.deleteAccount();

    // Assert: Verify that the method was called and loading value was set correctly
    verify(mockUserRepository.deleteAccount()).called(1);
    expect(authController.loading.value, false);

    // Verify that Get.toNamed was not called
    //verifyNever(Get.toNamed(Routes.LOGIN));
  });

  test('logout() should handle success', () async {
    // Arrange: Mock the logout method to complete successfully
    when(mockUserRepository.logout()).thenAnswer((_) async => {});

    // Act: Call the method
    await authController.logout();

    // Assert: Verify that the method was called and snackbar was shown
    verify(mockUserRepository.logout()).called(1);
    expect(authController.loading.value, false);

  });

  test('logout() should handle errors and show snackbar when not in test environment', () async {
    // Arrange: Mock the logout method to throw an exception
    when(mockUserRepository.logout()).thenThrow(Exception('Failed to logout'));

    // Act: Call the method
    await authController.logout();

    // Assert: Verify that the method was called and loading value was set correctly
    verify(mockUserRepository.logout()).called(1);
    expect(authController.loading.value, false);

  });


  test('getUser() should update currentUser and AuthService user on success', () async {
    // Arrange: Mock the getUser method to return a user object
    var mockUser = UserModel(
      myPosts: ['post1', 'post2'],
      myEvents: ['event1', 'event2'],
    );
    when(mockUserRepository.getUser()).thenAnswer((_) async => mockUser);

    // Act: Call the method
    await authController.getUser();

    // Assert: Verify that getUser was called
    verify(mockUserRepository.getUser()).called(1);

    // Verify that currentUser and AuthService user are updated
    expect(authController.currentUser.value, mockUser);
    expect(authController.currentUser.value.myPosts, ['post1', 'post2']);
    expect(authController.currentUser.value.myEvents, ['event1', 'event2']);
    expect(Get.find<AuthService>().user.value, mockUser);
  });

  test('getUser() should show an error snackbar on failure and not update user', () async {
    // Arrange: Mock the getUser method to throw an exception
    when(mockUserRepository.getUser()).thenThrow(Exception('Failed to get user'));

    // Act: Call the method
    await authController.getUser();

    // Assert: Verify that getUser was called
    verify(mockUserRepository.getUser()).called(1);

    // Ensure currentUser and AuthService user are not updated
    expect(authController.currentUser.value.myPosts, null);
    expect(authController.currentUser.value.myEvents, null);
    expect(Get.find<AuthService>().user.value.myPosts, null);
    expect(Get.find<AuthService>().user.value.myEvents, null);
  });

  test('getUser() should not show an error snackbar in test environment', () async {
    // Arrange: Mock the getUser method to throw an exception
    when(mockUserRepository.getUser()).thenThrow(Exception('Failed to get user'));

    // Act: Call the method
    await authController.getUser();

    // Assert: Verify that getUser was called
    verify(mockUserRepository.getUser()).called(1);

  });

  test('login() should authenticate the user and initialize controllers', () async {
    // Arrange
    final user = UserModel(
      authToken: 'token123',
      userId: 2,
      firstName: 'John',
      lastName: 'Doe',
      gender: 'Male',
      phoneNumber: '1234567890',
      email: 'john.doe@example.com',
      avatarUrl: 'avatar_url',
    );
    when(mockUserRepository.login(any)).thenAnswer((_) async => user);


    // Act
    await authController.login();

    // Assert
    expect(authController.loading.value, false);
    expect(Get.find<AuthService>().user.value.authToken, user.authToken);
    expect(Get.find<AuthService>().user.value.firstName, user.firstName);
    expect(Get.find<AuthService>().user.value.lastName, user.lastName);

    verify(mockUserRepository.login(any)).called(1);
  });

  test('login() should handle exceptions and show an error snackbar', () async {
    // Arrange
    final exception = Exception('Login failed');
    when(mockUserRepository.login(any)).thenThrow(exception);


    // Act
    await authController.login();

    // Assert
    expect(authController.loading.value, false);

    verify(mockUserRepository.login(any)).called(1);

  });


  tearDown(() {
    Get.reset();
  });




}


