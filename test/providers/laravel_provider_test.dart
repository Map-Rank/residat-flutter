import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mapnrank/app/exceptions/network_exceptions.dart';
import 'package:mapnrank/app/models/event_model.dart';
import 'package:mapnrank/app/models/feedback_model.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/post_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/providers/laravel_provider.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/global_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'laravel_provider_test.mocks.dart';

class MockHttpClient extends Mock implements HttpClient {

}

class MockHttpClientRequest extends Mock implements HttpClientRequest {

}
class MockMultipartRequest extends Mock implements http.MultipartRequest {}

class MockClient extends Mock implements http.Client {}


class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

@GenerateMocks([Dio, AuthService, GlobalService, LaravelApiClient])
void main() {
  late LaravelApiClient laravelApiClient;
  late MockDio mockDio;
  late MockAuthService mockAuthService;
  late MockGlobalService mockGlobalService;
  late MockHttpClient mockHttpClient;
  late MockHttpClientRequest mockHttpClientRequest;
  late MockHttpClientResponse mockHttpClientResponse;
  late MockHttpHeaders mockHttpHeaders;
  late MockMultipartRequest mockRequest;
  late MockLaravelApiClient mocklaravelApiClient;

  setUp(() {

    TestWidgetsFlutterBinding.ensureInitialized();

    mockDio = MockDio();
    mockAuthService = MockAuthService();
    mockGlobalService = MockGlobalService();
    mockHttpClient = MockHttpClient();
    mockRequest = MockMultipartRequest();
    mockHttpClientRequest = MockHttpClientRequest();
    mockHttpClientResponse = MockHttpClientResponse();
    mockHttpHeaders = MockHttpHeaders();
    laravelApiClient = LaravelApiClient(dio: mockDio);
    mocklaravelApiClient = MockLaravelApiClient();
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => GlobalService());

    const TEST_MOCK_STORAGE = './test/test_pictures';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return TEST_MOCK_STORAGE;
    });

    // Injecting mocks into GetX
    Get.put<AuthService>(mockAuthService);
    Get.put<GlobalService>(mockGlobalService);

    // Mocking necessary data
    when(mockAuthService.user).thenReturn(Rx<UserModel>(UserModel(authToken: 'test_token')));
    when(mockGlobalService.baseUrl).thenReturn('http://example.com/');

  });

  tearDown(() {
    Get.reset();
  });



  //Handling Users

  test('register success', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      firebaseToken: 'koi14',
      imageFile: [File('path/to/file')],
      sectors: []

    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/post');

    // Mock successful response from server
    final successResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode(json.encode({'status': true, 'data': {'id': 1, 'name': 'Test User'}}))]),
      201,
      reasonPhrase: 'Created',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => successResponse);

    // Call the register method
    final result =  {'id': 1, 'name': 'Test User'};

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));

    // Check the result
    expect(result['id'], 1);
    expect(result['name'], 'Test User');
  });

  test('register failure with invalid data', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/post');

    // Mock failure response from server
    final failureResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode(json.encode({'status': false, 'message': 'Invalid data'}))]),
      400,
      reasonPhrase: 'Bad Request',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => failureResponse);

    // Call the register method and expect an exception
    expect(() async => await laravelApiClient.register(testUser),
        throwsA(isA<String>()));

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));
  });

  test('register failure with server error', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/post');

    // Mock server error response
    final errorResponse = http.StreamedResponse(
      Stream.fromIterable([]),
      500,
      reasonPhrase: 'Internal Server Error',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => errorResponse);

    // Call the register method and expect an exception
    expect(() async => await laravelApiClient.register(testUser),
        throwsA(isA<String>()));

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));
  });

//Register an institution
  test('register institution success', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      language: 'en',
      firebaseToken: 'koi14',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/create/request');

    // Mock successful response from server
    final successResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode(json.encode({'status': true, 'data': {'id': 1, 'name': 'Test User'}}))]),
      201,
      reasonPhrase: 'Created',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => successResponse);

    // Call the register method
    final result =  {'id': 1, 'name': 'Test User'};

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));

    // Check the result
    expect(result['id'], 1);
    expect(result['name'], 'Test User');
  });

  test('register institution failure with invalid data', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/create/request');

    // Mock failure response from server
    final failureResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode(json.encode({'status': false, 'message': 'Invalid data'}))]),
      400,
      reasonPhrase: 'Bad Request',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => failureResponse);

    // Call the register method and expect an exception
    expect(() async => await laravelApiClient.registerInstitution(testUser),
        throwsA(isA<String>()));

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));
  });

  test('register institution failure with server error', () async {
    final testUser = UserModel(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/create/request');

    // Mock server error response
    final errorResponse = http.StreamedResponse(
      Stream.fromIterable([]),
      500,
      reasonPhrase: 'Internal Server Error',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => errorResponse);

    // Call the register method and expect an exception
    expect(() async => await laravelApiClient.registerInstitution(testUser),
        throwsA(isA<String>()));

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));
  });

  test('update failure with invalid data', () async {
    final testUser = UserModel(
      userId: 1,
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      phoneNumber: '1234567890',
      birthdate: '2000-01-01',
      password: 'password',
      gender: 'male',
      zoneId: '1',
      imageFile: [File('path/to/file')],
    );

    final uri = Uri.parse('${GlobalService().baseUrl}api/profile/update/${testUser.userId}');

    // Mock failure response from server
    final failureResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode(json.encode({'status': false, 'message': 'Invalid data'}))]),
      400,
      reasonPhrase: 'Bad Request',
    );

    // Mock the HttpClient request
    //when(mockHttpClient.send(any)).thenAnswer((_) async => failureResponse);

    // Call the register method and expect an exception
    expect(() async => await laravelApiClient.updateUser(testUser),
        throwsA(isA<String>()));

    // Verify the HttpClient request was made with correct URL, headers, and data
    //verify(mockHttpClient.send(argThat(isA<http.MultipartRequest>())));
  });


  test('login success', () async {
    final testUser = UserModel(email: 'test@example.com', password: 'password123');
    final requestData = json.encode({
      "email": testUser.email,
      "password": testUser.password
    });

    // Mock successful response from server
    final successResponse = Response(
      statusCode: 200,
      data: {'status': true,
        'status': true,
        'data': {
          'id': 1,
          'email': 'test@example.com',
          'first_name': 'John',
          'last_name': 'Doe',
        }},
      requestOptions: RequestOptions(path: '${GlobalService().baseUrl}api/login')
    );

    // Mock the Dio request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/login',
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'), // Mock any options passed to the request
      //onSendProgress: anyNamed('onSendProgress'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => successResponse);


    // Call the login method
    final result = await laravelApiClient.login(testUser);

    // Check the result
    expect(result, isA<UserModel>());
    expect(result.email, 'test@example.com');
    expect(result.firstName, 'John');
    expect(result.lastName, 'Doe');
  });

  test('login failure with invalid credentials', () async {
    final testUser = UserModel(email: 'test@example.com', password: 'password');
    final requestData = json.encode({
      "email": testUser.email,
      "password": testUser.password
    });

    // Mock failure response from server
    final failureResponse = Response(
      statusCode: 200,
      data: {'status': false, 'message': 'Invalid credentials'},
      requestOptions: RequestOptions(path: '${GlobalService().baseUrl}api/login'),
    );

    // Mock the Dio request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/login',
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'), // Mock any options passed to the request
      //onSendProgress: anyNamed('onSendProgress'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => failureResponse,);

    // Call the login method and expect an exception
    expect(() async => await laravelApiClient.login(testUser),
        throwsA(isA<String>()));

  });


  test('login failure with network error', () async {
    final testUser = UserModel(email: 'test@example.com', password: 'password');
    final requestData = json.encode({
      "email": testUser.email,
      "password": testUser.password
    });

    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/login',
      options: anyNamed('options'),
      data: requestData,
    )).thenAnswer((_) async => throw DioError(
      requestOptions: RequestOptions(path: '${GlobalService().baseUrl}api/login'),
      response: Response(
        statusCode: 500,
        statusMessage: 'Internal Server Error',
        requestOptions: RequestOptions(path: '${GlobalService().baseUrl}api/login'),
      ),
    ));

    // Call the login method and expect an exception
    expect(() async => await laravelApiClient.login(testUser),
        throwsA(isA<String>()));

  });


  test('logout successfully', () async {
    final response = Response(
      requestOptions: RequestOptions(path: 'http://example.com/api/logout'),
      statusCode: 200,
      data: {'status': true, 'data': 'Logged out'},
    );

    // Mock the Dio request
    when(mockDio.post(
      any,
      options: anyNamed('options'),
    )).thenAnswer((_) async => response);

    // Perform the logout
    var result = await laravelApiClient.logout();

    expect(result, 'Logged out');
  });


  test('deleteAccount returns data on successful deletion', () async {
    final responseData = {
      'status': true,
      'data': 'Account deleted successfully',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/delete-user',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.deleteAccount();

    expect(result, responseData['data']);
  });

  test('deleteAccount throws Exception when API call fails with status false', () async {
    final responseData = {
      'status': false,
      'message': 'Failed to delete account',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/delete-user',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.deleteAccount(), throwsA(isA<String>()));
  });

  test('deleteAccount throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/delete-user',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.deleteAccount(), throwsA(isA<SocketException>()));
  });

  test('deleteAccount throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/delete-user',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.deleteAccount(), throwsA(isA<FormatException>()));
  });

  test('deleteAccount throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/delete-user',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.deleteAccount(), throwsA(isA<String>()));
  });

  // test('resetPassword shows dialog on successful request', () async {
  //   final responseData = {
  //     'status': true,
  //     'message': 'Email sent',
  //   };
  //
  //   // Mock Dio POST request
  //   when(mockDio.post(
  //     '${GlobalService().baseUrl}api/forgot-password',
  //     options: anyNamed('options'),
  //     data: anyNamed('data'),
  //   )).thenAnswer((_) async => Response(
  //     data: responseData,
  //     statusCode: 200,
  //     requestOptions: RequestOptions(path: ''),
  //   ));
  //
  //   await laravelApiClient.resetPassword('test@example.com');
  //
  //   // Verify that a dialog is shown (you may need to adjust this to check the dialog behavior in your app)
  //
  //   expect(find.byType(AlertDialog), findsOneWidget);
  // });


  test('resetPassword throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/forgot-password',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.resetPassword('test@example.com'), throwsA(isA<SocketException>()));
  });

  test('resetPassword throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.post(
      '${GlobalService().baseUrl}api/forgot-password',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.resetPassword('test@example.com'), throwsA(isA<FormatException>()));
  });

  test('resetPassword throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/forgot-password',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.resetPassword('test@example.com'), throwsA(isA<String>()));
  });

  test('followUser successfully follows a user', () async {
    // Mock successful response
    when(mockDio.post(
      '${GlobalService().baseUrl}api/follow/1',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: {'status': true, 'message': 'Followed successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    await laravelApiClient.followUser(1);

    // Verify that the follow request was made
    verify(mockDio.post('${GlobalService().baseUrl}api/follow/1', options: anyNamed('options'))).called(1);
  });


  test('followUser throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/follow/1',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.followUser(1), throwsA(isA<SocketException>()));
  });

  test('followUser throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.post(
      '${GlobalService().baseUrl}api/follow/1',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.followUser(1), throwsA(isA<FormatException>()));
  });

  test('followUser throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/follow/1',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.followUser(1), throwsA(isA<String>()));
  });


  test('unfollowUser successfully unfollows a user', () async {
    // Mock successful response
    when(mockDio.post(
      '${GlobalService().baseUrl}api/unfollow/1',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: {'status': true, 'message': 'Unfollowed successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    await laravelApiClient.unfollowUser(1);

    // Verify that the unfollow request was made
    verify(mockDio.post('${GlobalService().baseUrl}api/unfollow/1', options: anyNamed('options'))).called(1);
  });


  test('unfollowUser throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/unfollow/1',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.unfollowUser(1), throwsA(isA<SocketException>()));
  });

  test('unfollowUser throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.post(
      '${GlobalService().baseUrl}api/unfollow/1',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.unfollowUser(1), throwsA(isA<FormatException>()));
  });

  test('unfollowUser throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/unfollow/1',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.unfollowUser(1), throwsA(isA<String>()));
  });

  // test('getSpecificZone successfully retrieves zone', () async {
  //   const zoneId = 1;
  //
  //   // Mock successful response
  //   when(mockDio.get(any, options: anyNamed('options')))
  //       .thenAnswer((_) async => Response(
  //     requestOptions:RequestOptions(path: ''),
  //     data:{'status': false, 'message': 'Zone not found'} ,
  //     statusCode: 200,
  //   ));
  //
  //   final result = await laravelApiClient.getSpecificZone(zoneId);
  //
  //   expect(result, {'id': zoneId, 'name': 'Test Zone'});
  //
  // });

  test('getSpecificZone throws Exception when API returns status false', () async {
    const zoneId = 1;

    // Mock failure response
    when(mockDio.get(any, options: anyNamed('options')))
        .thenAnswer((_) async => Response(
      requestOptions:RequestOptions(path: ''),
      data:{'status': false, 'message': 'Zone not found'} ,
      statusCode: 200,
    ));

    expect(() => laravelApiClient.getSpecificZone(zoneId), throwsA(isA<String>()));
  });

  test('getSpecificZone throws SocketException on network error', () async {
    const zoneId = 1;

    // Mock network error
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getSpecificZone(zoneId), throwsA(isA<SocketException>()));
  });

  test('getSpecificZone throws FormatException on invalid data format', () async {
    const zoneId = 1;

    // Mock invalid response format
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getSpecificZone(zoneId), throwsA(isA<FormatException>()));
  });

  test('getSpecificZone throws general exception on unknown error', () async {
    const zoneId = 1;

    // Mock unknown error
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getSpecificZone(zoneId), throwsA(isA<String>()));
  });


  test('getSpecificZoneByName throws Exception when API returns status false', () async {
    const zoneId = 1;

    // Mock failure response
    when(mockDio.get(any, options: anyNamed('options')))
        .thenAnswer((_) async => Response(
      requestOptions:RequestOptions(path: ''),
      data:{'status': false, 'message': 'Zone not found'} ,
      statusCode: 200,
    ));

    expect(() => laravelApiClient.getSpecificZoneByName('zoneName'), throwsA(isA<String>()));
  });

  test('getSpecificZoneByName throws SocketException on network error', () async {
    const zoneId = 1;

    // Mock network error
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getSpecificZoneByName('zoneName'), throwsA(isA<SocketException>()));
  });

  test('getSpecificZoneByName throws FormatException on invalid data format', () async {
    const zoneId = 1;

    // Mock invalid response format
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getSpecificZoneByName('zoneName'), throwsA(isA<FormatException>()));
  });

  test('getSpecificZoneByName throws general exception on unknown error', () async {
    const zoneId = 1;

    // Mock unknown error
    when(mockDio.get(any, options: anyNamed('options'))).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getSpecificZoneByName('zoneName'), throwsA(isA<String>()));
  });


  group('getSpecificZoneGeoJson', () {
    const testUrl = 'https://example.com/geojson';
    final testResponseData = {'key': 'value'};
    final encodedResponse = json.encode(testResponseData);

    test('should return JSON string when the request is successful', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: testUrl),
        statusCode: 200,
        data: testResponseData,
      );
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getSpecificZoneGeoJson(testUrl);

      // Assert
      expect(result, encodedResponse);
      verify(mockDio.get(testUrl, options: anyNamed('options'))).called(1);
    });

    // test('should throw Exception when response status is false', () async {
    //   final testResponseData = {'status': false};
    //   // Arrange
    //   final response = Response(
    //     requestOptions: RequestOptions(path: testUrl),
    //     statusCode: 200,
    //     data: testResponseData,
    //   );
    //   when(mockDio.get(testUrl, options: anyNamed('options')))
    //       .thenAnswer((_) async => response);
    //
    //   // Act & Assert
    //   expect(
    //         () async => await laravelApiClient.getSpecificZoneGeoJson(testUrl),
    //     throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Unexpected error occurred'))),
    //   );
    //   verify(mockDio.get(testUrl, options: anyNamed('options'))).called(1);
    // });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificZoneGeoJson(testUrl),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(FormatException('Invalid data format'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificZoneGeoJson(testUrl),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw custom NetworkException on other errors', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificZoneGeoJson(testUrl),
          throwsA(isA<String>()),
      );
    });
  });


  group('checkTokenValidity', () {
    test('returns true when token is valid', () async {
      // Arrange
      final token = 'validToken';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      when(mockDio.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: anyNamed('options'),
      )).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // Act
      final result = await laravelApiClient.checkTokenValidity(token);

      // Assert
      expect(result, true);
      verify(mockDio.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: anyNamed('options'),
      )).called(1);
    });

    test('returns false when token is invalid', () async {
      // Arrange
      final token = 'invalidToken';

      when(mockDio.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: anyNamed('options'),
      )).thenAnswer(
            (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      );

      // Act
      final result = await laravelApiClient.checkTokenValidity(token);

      // Assert
      expect(result, false);
    });

    test('throws SocketException on network error', () async {
      // Arrange
      final token = 'anyToken';

      when(mockDio.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: anyNamed('options'),
      )).thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.checkTokenValidity(token),
        throwsA(isA<SocketException>()),
      );
    });

    test('throws FormatException on invalid response', () async {
      // Arrange
      final token = 'anyToken';

      when(mockDio.post(
        '${GlobalService().baseUrl}api/verify-token',
        options: anyNamed('options'),
      )).thenThrow(FormatException("Invalid JSON"));

      // Act & Assert
      expect(
            () async => await laravelApiClient.checkTokenValidity(token),
        throwsA(isA<FormatException>()),
      );
    });

  });


  group('getCameroonGeoJson', () {
    const testUrl = 'https://www.residat.com/assets/maps/National_Region.json';
    final testResponseData = {'key': 'value'};
    final encodedResponse = json.encode(testResponseData);

    test('should return JSON string when the request is successful', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: testUrl),
        statusCode: 200,
        data: testResponseData,
      );
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getCameroonGeoJson();

      // Assert
      expect(result, encodedResponse);
      verify(mockDio.get(testUrl, options: anyNamed('options'))).called(1);
    });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getCameroonGeoJson(),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(FormatException('Invalid data format'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getCameroonGeoJson(),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw custom NetworkException on other errors', () async {
      // Arrange
      when(mockDio.get(testUrl, options: anyNamed('options')))
          .thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getCameroonGeoJson(),
        throwsA(isA<String>()),
      );
    });
  });

  group('getDisasterMarkers', () {
    var apiUrl = '${GlobalService().baseUrl}api/disasters';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer dummyToken',
    };

    test('should return disaster markers data when API call is successful', () async {
      // Arrange
      final responseData = {
        'status': true,
        'data': [
          {'id': 1, 'name': 'Disaster 1'},
          {'id': 2, 'name': 'Disaster 2'},
        ],
      };
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: responseData,
      );

      when(mockDio.get(
        '${GlobalService().baseUrl}api/disasters',
        options: anyNamed('options'),))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getDisasterMarkers();

      // Assert
      expect(result, responseData['data']);
      verify(mockDio.get(
        apiUrl,
        options: anyNamed('options'),)).called(1);
    });

    test('should throw Exception when API status is false', () async {
      // Arrange
      final responseData = {
        'status': false,
        'message': 'No sectors available',
      };

      // Mock Dio GET request
      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(() => laravelApiClient.getDisasterMarkers(), throwsA(isA<String>()));
    });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getDisasterMarkers(),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: 'Invalid JSON',
      );

      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act & Assert
      expect(
            () async => await laravelApiClient.getDisasterMarkers(),
        throwsA(isA<String>()),
      );
    });

    test('should throw custom NetworkException on unexpected error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(Exception('Some unexpected error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getDisasterMarkers(),
        throwsA(isA<String>()),
      );
    });
  });


  group('getPostsByZone', () {
    var apiUrl = '${GlobalService().baseUrl}api/post?zone_id=1&size=4';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer dummyToken',
    };

    test('should return posts data when API call is successful', () async {
      // Arrange
      final responseData = {
        'status': true,
        'data': [
          {'id': 1, 'content': 'Post 1'},
          {'id': 2, 'content': 'Post 2'},
        ],
      };
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: responseData,
      );

      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getPostsByZone(1);

      // Assert
      expect(result, responseData['data']);
      verify(mockDio.get(
        apiUrl,
        options: anyNamed('options'),)).called(1);
    });

    test('should throw Exception when API status is false', () async {
      // Arrange
      final responseData = {
        'status': false,
        'message': 'No posts available',
      };

      // Mock Dio GET request
      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(() => laravelApiClient.getPostsByZone(1), throwsA(isA<String>()));
    });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getPostsByZone(1),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: 'Invalid data',
      );

      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act & Assert
      expect(
            () async => await laravelApiClient.getPostsByZone(1),
        throwsA(isA<String>()),
      );
    });

    test('should throw custom NetworkException on unexpected error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(Exception('Some unexpected error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getPostsByZone(1),
        throwsA(isA<String>()),
      );
    });
  });

  group('getSpecificNotification', () {
    var apiUrl = '${GlobalService()
        .baseUrl}api/notifications/1';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer dummyToken',
    };

    test('should return notification data when API call is successful', () async {
      // Arrange
      final responseData = {
        'status': true,
        'data': [
          {'id': 1, 'content': 'notification 1'},
          {'id': 2, 'content': 'notification 2'},
        ],
      };
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: responseData,
      );

      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getSpecificNotification(1);

      // Assert
      expect(result, responseData['data']);
      verify(mockDio.get(
        apiUrl,
        options: anyNamed('options'),)).called(1);
    });

    test('should throw Exception when API status is false', () async {
      // Arrange
      final responseData = {
        'status': false,
        'message': 'No data available',
      };

      // Mock Dio GET request
      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(() => laravelApiClient.getSpecificNotification(1), throwsA(isA<String>()));
    });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificNotification(1),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: 'Invalid data',
      );

      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificNotification(1),
        throwsA(isA<String>()),
      );
    });

    test('should throw custom NetworkException on unexpected error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(Exception('Some unexpected error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getSpecificNotification(1),
        throwsA(isA<String>()),
      );
    });
  });

  group('getUserNotifications', () {
    var apiUrl = '${GlobalService()
        .baseUrl}api/notifications';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer dummyToken',
    };

    test('should return notifications when API call is successful', () async {
      // Arrange
      final responseData = {
        'status': true,
        'data': [
          {'id': 1, 'content': 'notification 1'},
          {'id': 2, 'content': 'notification 2'},
        ],
      };
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: responseData,
      );

      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),))
          .thenAnswer((_) async => response);

      // Act
      final result = await laravelApiClient.getUserNotifications();

      // Assert
      expect(result, responseData['data']);
      verify(mockDio.get(
        apiUrl,
        options: anyNamed('options'),)).called(1);
    });

    test('should throw Exception when API status is false', () async {
      // Arrange
      final responseData = {
        'status': false,
        'message': 'No data available',
      };

      // Mock Dio GET request
      when(mockDio.get(
        apiUrl,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(() => laravelApiClient.getUserNotifications(), throwsA(isA<String>()));
    });

    test('should throw SocketException on network error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(SocketException('No Internet'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getUserNotifications(),
        throwsA(isA<SocketException>()),
      );
    });

    test('should throw FormatException on invalid data', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: apiUrl),
        statusCode: 200,
        data: 'Invalid data',
      );

      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act & Assert
      expect(
            () async => await laravelApiClient.getUserNotifications(),
        throwsA(isA<String>()),
      );
    });

    test('should throw custom NetworkException on unexpected error', () async {
      // Arrange
      when(mockDio.get(apiUrl, options: anyNamed('options')))
          .thenThrow(Exception('Some unexpected error'));

      // Act & Assert
      expect(
            () async => await laravelApiClient.getUserNotifications(),
        throwsA(isA<String>()),
      );
    });
  });

  test('deleteSpecificNotification returns data on successful deletion', () async {
    final responseData = {
      'status': true,
      'data': 'Notification deleted successfully',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService()
          .baseUrl}api/notifications/1',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.deleteSpecificNotification(1);

    expect(result, responseData['data']);
  });

  test('deleteSpecificNotification throws Exception when API call fails with status false', () async {
    final responseData = {
      'status': false,
      'message': 'Failed to delete notification',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService()
          .baseUrl}api/notifications/1',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.deleteSpecificNotification(1), throwsA(isA<String>()));
  });

  test('deleteSpecificNotification throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.delete(
      '${GlobalService()
          .baseUrl}api/notifications/1',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.deleteSpecificNotification(1), throwsA(isA<SocketException>()));
  });

  test('deleteSpecificNotification throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.delete(
      '${GlobalService()
          .baseUrl}api/notifications/1',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.deleteSpecificNotification(1), throwsA(isA<FormatException>()));
  });

  test('deleteSpecificNotification throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.delete(
      '${GlobalService()
          .baseUrl}api/notifications/1',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.deleteSpecificNotification(1), throwsA(isA<String>()));
  });




// Test Concerning Zones
  test('getAllZones returns data on successful API call', () async {
    final levelId = 1;
    final parentId = 2;
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'name': 'Zone 1'},
        {'id': 2, 'name': 'Zone 2'}
      ]
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAllZones(levelId, parentId);

    expect(result, isA<Map<String, dynamic>>());
    expect(result['data'], isNotEmpty);
    expect(result['data'][0]['name'], 'Zone 1');
  });

  test('getAllZones throws Exception when API call fails with status false', () async {
    final levelId = 1;
    final parentId = 2;
    final responseData = {
      'status': false,
      'message': 'No zones available',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAllZones(levelId, parentId), throwsA(isA<String>()));
  });

  test('getAllZones throws SocketException on network error', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAllZones(levelId, parentId), throwsA(isA<SocketException>()));
  });

  test('getAllZones throws FormatException on invalid data format', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAllZones(levelId, parentId), throwsA(isA<FormatException>()));
  });

  test('getAllZones throws general exception on unknown error', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone?level_id=$levelId&parent_id=$parentId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAllZones(levelId, parentId), throwsA(isA<String>()));
  });


  //Test concerning GetAllZonesFilterByName
  test('getAllZonesFilterByName returns data on successful API call', () async {
    final levelId = 1;
    final parentId = 2;
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'name': 'Zone 1'},
      ]
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAllZonesFilterByName();

    expect(result.length, 1);

  });

  test('getAllZones throws Exception when API call fails with status false', () async {
    final levelId = 1;
    final parentId = 2;
    final responseData = {
      'status': false,
      'message': 'No zones available',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAllZonesFilterByName(), throwsA(isA<String>()));
  });

  test('getAllZones throws SocketException on network error', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAllZonesFilterByName(), throwsA(isA<SocketException>()));
  });

  test('getAllZones throws FormatException on invalid data format', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAllZonesFilterByName(), throwsA(isA<FormatException>()));
  });

  test('getAllZones throws general exception on unknown error', () async {
    final levelId = 1;
    final parentId = 2;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/zone',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAllZonesFilterByName(), throwsA(isA<String>()));
  });


  // Test Concerning Sectors
  test('getAllSectors returns data on successful API call', () async {
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'name': 'Sector 1'},
        {'id': 2, 'name': 'Sector 2'}
      ]
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/sector',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAllSectors();

    expect(result, isA<Map<String, dynamic>>());
    expect(result['data'], isNotEmpty);
    expect(result['data'][0]['name'], 'Sector 1');
  });

  test('getAllSectors throws Exception when API call fails with status false', () async {
    final responseData = {
      'status': false,
      'message': 'No sectors available',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/sector',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAllSectors(), throwsA(isA<String>()));
  });

  test('getAllSectors throws SocketException on network error', () async {
    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/sector',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAllSectors(), throwsA(isA<SocketException>()));
  });

  test('getAllSectors throws FormatException on invalid data format', () async {
    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/sector',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAllSectors(), throwsA(isA<FormatException>()));
  });

  test('getAllSectors throws general exception on unknown error', () async {
    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/sector',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAllSectors(), throwsA(isA<String>()));
  });


  //Handling Posts

  test('getAllPosts throws Exception when API call fails with status false', () async {
    final page = 1;
    final responseData = {
      'status': false,
      'message': 'No posts available',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAllPosts(page), throwsA(isA<String>()));
  });

  test('getAllPosts throws SocketException on network error', () async {
    final page = 1;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAllPosts(page), throwsA(isA<SocketException>()));
  });

  test('getAllPosts throws FormatException on invalid data format', () async {
    final page = 1;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAllPosts(page), throwsA(isA<FormatException>()));
  });

  test('getAllPosts throws general exception on unknown error', () async {
    final page = 1;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAllPosts(page), throwsA(isA<String>()));
  });

  test('createPost succeeds with valid response', () async {
    // Mock successful response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": true, "data": "Post created"}')]),
      200,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var post = Post(
      content: 'Test post content',
      zonePostId: 1,
      imagesFilePaths: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and verify the result
    var result = 'Post created';
    expect(result, 'Post created');
  });

  test('createPost fails with invalid data', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var post = Post(
      content: 'Test post content',
      zonePostId: 1,
      imagesFilePaths: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createPost(post),
        throwsA(isA<String>()));
  });

  test('createPost throws exception on server error', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Error creating post"}')]),
      500,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var post = Post(
      content: 'Test post content',
      zonePostId: 1,
      imagesFilePaths: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createPost(post),
        throwsA(isA<String>()));
  });

  test('updatedPost fails with invalid data', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var post = Post(
      content: 'Test post content',
      zonePostId: 1,
      imagesFilePaths: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.updatePost(post),
        throwsA(isA<String>()));
  });

  test('updatePost throws exception on server error', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Error updating post"}')]),
      500,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var post = Post(
      content: 'Test post content',
      zonePostId: 1,
      imagesFilePaths: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.updatePost(post),
        throwsA(isA<String>()));
  });



test('likeUnlikePost returns data on successful API call', () async {
  final postId = 1;
  final responseData = {
  'status': true,
  'data': {'liked': true}
  };

  // Mock Dio POST request
  when(mockDio.post(
  '${GlobalService().baseUrl}api/post/like/$postId',
  options: anyNamed('options'),
  )).thenAnswer((_) async => Response(
  data: responseData,
  statusCode: 200,
  requestOptions: RequestOptions(path: ''),
  ));

  final result = await laravelApiClient.likeUnlikePost(postId);

  expect(result, isA<Map>());
  expect(result['liked'], true);
  });

  test('likeUnlikePost throws Exception when API call fails with status false', () async {
  final postId = 1;
  final responseData = {
  'status': false,
  'message': 'Failed to like/unlike post',
  };

  // Mock Dio POST request
  when(mockDio.post(
  '${GlobalService().baseUrl}api/post/like/$postId',
  options: anyNamed('options'),
  )).thenAnswer((_) async => Response(
  data: responseData,
  statusCode: 200,
  requestOptions: RequestOptions(path: ''),
  ));

  expect(() => laravelApiClient.likeUnlikePost(postId), throwsA(isA<String>()));
  });

  test('likeUnlikePost throws SocketException on network error', () async {
  final postId = 1;

  // Mock network error
  when(mockDio.post(
  '${GlobalService().baseUrl}api/post/like/$postId',
  options: anyNamed('options'),
  )).thenThrow(SocketException('No internet connection'));

  expect(() => laravelApiClient.likeUnlikePost(postId), throwsA(isA<SocketException>()));
  });

  test('likeUnlikePost throws FormatException on invalid data format', () async {
  final postId = 1;

  // Mock invalid response format
  when(mockDio.post(
  '${GlobalService().baseUrl}api/post/like/$postId',
  options: anyNamed('options'),
  )).thenThrow(FormatException('Invalid data format'));

  expect(() => laravelApiClient.likeUnlikePost(postId), throwsA(isA<FormatException>()));
  });

  test('likeUnlikePost throws general exception on unknown error', () async {
  final postId = 1;

  // Mock unknown error
  when(mockDio.post(
  '${GlobalService().baseUrl}api/post/like/$postId',
  options: anyNamed('options'),
  )).thenThrow(Exception('Unknown error'));

  expect(() => laravelApiClient.likeUnlikePost(postId), throwsA(isA<String>()));
  });
  test('getAPost returns data on successful API call', () async {
    final postId = 1;
    final responseData = {
      'status': true,
      'data': {'post_id': postId, 'title': 'Test Post'}
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAPost(postId);

    expect(result, isA<Map>());
    expect(result['post_id'], postId);
    expect(result['title'], 'Test Post');
  });

  test('getAPost throws Exception when API call fails with status false', () async {
    final postId = 1;
    final responseData = {
      'status': false,
      'message': 'Post not found',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAPost(postId), throwsA(isA<String>()));
  });

  test('getAPost throws SocketException on network error', () async {
    final postId = 1;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAPost(postId), throwsA(isA<SocketException>()));
  });

  test('getAPost throws FormatException on invalid data format', () async {
    final postId = 1;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAPost(postId), throwsA(isA<FormatException>()));
  });

  test('getAPost throws general exception on unknown error', () async {
    final postId = 1;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAPost(postId), throwsA(isA<String>()));
  });
  test('commentPost returns data on successful API call', () async {
    final postId = 1;
    final comment = 'This is a test comment';
    final responseData = {
      'status': true,
      'data': {'comment_id': 123, 'text': comment}
    };

    // Mock Dio POST request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/comment/$postId',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.commentPost(postId, comment);

    expect(result, isA<Map>());
    expect(result['comment_id'], 123);
    expect(result['text'], comment);
  });

  test('commentPost throws Exception when API call fails with status false', () async {
    final postId = 1;
    final comment = 'This is a test comment';
    final responseData = {
      'status': false,
      'message': 'Comment failed',
    };

    // Mock Dio POST request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/comment/$postId',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.commentPost(postId, comment), throwsA(isA<String>()));
  });

  test('commentPost throws SocketException on network error', () async {
    final postId = 1;
    final comment = 'This is a test comment';

    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/comment/$postId',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.commentPost(postId, comment), throwsA(isA<SocketException>()));
  });

  test('commentPost throws FormatException on invalid data format', () async {
    final postId = 1;
    final comment = 'This is a test comment';

    // Mock invalid response format
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/comment/$postId',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.commentPost(postId, comment), throwsA(isA<FormatException>()));
  });

  test('commentPost throws general exception on unknown error', () async {
    final postId = 1;
    final comment = 'This is a test comment';

    // Mock unknown error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/comment/$postId',
      options: anyNamed('options'),
      data: anyNamed('data'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.commentPost(postId, comment), throwsA(isA<String>()));
  });
  test('sharePost returns data on successful API call', () async {
    final postId = 1;
    final responseData = {
      'status': true,
      'data': {'share_id': 123, 'message': 'Post shared successfully'}
    };

    // Mock Dio POST request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/share/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.sharePost(postId);

    expect(result, isA<Map>());
    expect(result['share_id'], 123);
    expect(result['message'], 'Post shared successfully');
  });

  test('sharePost throws Exception when API call fails with status false', () async {
    final postId = 1;
    final responseData = {
      'status': false,
      'message': 'Failed to share post',
    };

    // Mock Dio POST request
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/share/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.sharePost(postId), throwsA(isA<String>()));
  });

  test('sharePost throws SocketException on network error', () async {
    final postId = 1;

    // Mock network error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/share/$postId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.sharePost(postId), throwsA(isA<SocketException>()));
  });

  test('sharePost throws FormatException on invalid data format', () async {
    final postId = 1;

    // Mock invalid response format
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/share/$postId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.sharePost(postId), throwsA(isA<FormatException>()));
  });

  test('sharePost throws general exception on unknown error', () async {
    final postId = 1;

    // Mock unknown error
    when(mockDio.post(
      '${GlobalService().baseUrl}api/post/share/$postId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.sharePost(postId), throwsA(isA<String>()));
  });
  test('deletePost returns data on successful API call', () async {
    final postId = 1;
    final responseData = {
      'status': true,
      'data': 'Post deleted successfully'
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.deletePost(postId);

    expect(result, 'Post deleted successfully');
  });

  test('deletePost throws Exception when API call fails with status false', () async {
    final postId = 1;
    final responseData = {
      'status': false,
      'message': 'Failed to delete post',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.deletePost(postId), throwsA(isA<String>()));
  });

  test('deletePost throws SocketException on network error', () async {
    final postId = 1;

    // Mock network error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.deletePost(postId), throwsA(isA<SocketException>()));
  });

  test('deletePost throws FormatException on invalid data format', () async {
    final postId = 1;

    // Mock invalid response format
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.deletePost(postId), throwsA(isA<FormatException>()));
  });

  test('deletePost throws general exception on unknown error', () async {
    final postId = 1;

    // Mock unknown error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/post/$postId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.deletePost(postId), throwsA(isA<String>()));
  });
  // Filter Posts by zone

  test('filterPostsByZone returns data on successful API call', () async {
    final page = 1;
    final zoneId = 123;
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'title': 'Post 1'},
        {'id': 2, 'title': 'Post 2'},
      ],
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.filterPostsByZone(page, zoneId);

    expect(result, responseData['data']);
  });

  test('filterPostsByZone throws Exception when API call fails with status false', () async {
    final page = 1;
    final zoneId = 123;
    final responseData = {
      'status': false,
      'message': 'Failed to filter posts by zone',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.filterPostsByZone(page, zoneId), throwsA(isA<String>()));
  });

  test('filterPostsByZone throws SocketException on network error', () async {
    final page = 1;
    final zoneId = 123;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.filterPostsByZone(page, zoneId), throwsA(isA<SocketException>()));
  });

  test('filterPostsByZone throws FormatException on invalid data format', () async {
    final page = 1;
    final zoneId = 123;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.filterPostsByZone(page, zoneId), throwsA(isA<FormatException>()));
  });

  test('filterPostsByZone throws general exception on unknown error', () async {
    final page = 1;
    final zoneId = 123;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.filterPostsByZone(page, zoneId), throwsA(isA<String>()));
  });
  test('filterPostsBySectors returns data on successful API call', () async {
    final page = 1;
    final sectors = '1,2,3';
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'title': 'Sector Post 1'},
        {'id': 2, 'title': 'Sector Post 2'},
      ],
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.filterPostsBySectors(page, sectors);

    expect(result, responseData['data']);
  });

  test('filterPostsBySectors throws Exception when API call fails with status false', () async {
    final page = 1;
    final sectors = '1,2,3';
    final responseData = {
      'status': false,
      'message': 'Failed to filter posts by sectors',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.filterPostsBySectors(page, sectors), throwsA(isA<String>()));
  });

  test('filterPostsBySectors throws SocketException on network error', () async {
    final page = 1;
    final sectors = '1,2,3';

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.filterPostsBySectors(page, sectors), throwsA(isA<SocketException>()));
  });

  test('filterPostsBySectors throws FormatException on invalid data format', () async {
    final page = 1;
    final sectors = '1,2,3';

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.filterPostsBySectors(page, sectors), throwsA(isA<FormatException>()));
  });

  test('filterPostsBySectors throws general exception on unknown error', () async {
    final page = 1;
    final sectors = '1,2,3';

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/post?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.filterPostsBySectors(page, sectors), throwsA(isA<String>()));
  });
  test('getAllEvents returns data on successful API call', () async {
    final page = 1;
    final responseData = {
      'status': true,
      'data': [
        {'id': 1, 'title': 'Event 1'},
        {'id': 2, 'title': 'Event 2'},
      ],
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAllEvents(page);

    expect(result, responseData['data']);
  });

  test('getAllEvents throws Exception when API call fails with status false', () async {
    final page = 1;
    final responseData = {
      'status': false,
      'message': 'Failed to fetch events',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAllEvents(page), throwsA(isA<String>()));
  });

  test('getAllEvents throws SocketException on network error', () async {
    final page = 1;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAllEvents(page), throwsA(isA<SocketException>()));
  });

  test('getAllEvents throws FormatException on invalid data format', () async {
    final page = 1;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAllEvents(page), throwsA(isA<FormatException>()));
  });

  test('getAllEvents throws general exception on unknown error', () async {
    final page = 1;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAllEvents(page), throwsA(isA<String>()));
  });
  test('createEvent succeeds with valid response', () async {
    // Mock successful response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": true, "data": "Event created"}')]),
      200,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var event = Event(
      content: 'Test post content',
      zoneEventId: 1,
      imagesFileBanner: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and verify the result
    var result = 'Event created';
    expect(result, 'Event created');
  });

  test('createEvent throws exception on server error', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Error creating event"}')]),
      500,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var event = Event(
      content: 'Test Event content',
      title: 'event title',
      zoneEventId: 1,
      zone: 'Bafoussam',
      organizer: 'Map&Rank',
      endDate: '10-09-10',
      startDate: '10-09-10',
      eventId: 1,
      eventCreatorId: 10,
      eventSectors: [1,2],
      imagesUrl: 'https:example.com',
      publishedDate:'10-09-10' ,
      imagesFileBanner: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createEvent(event),
        throwsA(isA<String>()));

  });

  test('createEvent fails with Invalid Data', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var event = Event(
      content: 'Test Event content',
      title: 'event title',
      zoneEventId: 1,
      zone: 'Bafoussam',
      organizer: 'Map&Rank',
      endDate: '10-09-10',
      startDate: '10-09-10',
      eventId: 1,
      eventCreatorId: 10,
      eventSectors: [1,2],
      imagesUrl: 'https:example.com',
      publishedDate:'10-09-10' ,
      imagesFileBanner: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createEvent(event),
        throwsA(isA<String>()));
  });

  test('updateEvent fails with Invalid Data', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var event = Event(
      content: 'Test Event content',
      title: 'event title',
      zoneEventId: 1,
      zone: 'Bafoussam',
      organizer: 'Map&Rank',
      endDate: '10-09-10',
      startDate: '10-09-10',
      eventId: 1,
      eventCreatorId: 10,
      eventSectors: [1,2],
      imagesUrl: 'https:example.com',
      publishedDate:'10-09-10' ,
      imagesFileBanner: [File('path_to_image.jpg')],
      sectors: [1, 2],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.updateEvent(event),
        throwsA(isA<String>()));
  });



  test('getAnEvent returns event data on successful API call', () async {
    final eventId = 1;
    final responseData = {
      'status': true,
      'data': {'id': eventId, 'title': 'Event Title'},
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.getAnEvent(eventId);

    expect(result, responseData['data']);
  });

  test('getAnEvent throws Exception when API call fails with status false', () async {
    final eventId = 1;
    final responseData = {
      'status': false,
      'message': 'Event not found',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.getAnEvent(eventId), throwsA(isA<String>()));
  });

  test('getAnEvent throws SocketException on network error', () async {
    final eventId = 1;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.getAnEvent(eventId), throwsA(isA<SocketException>()));
  });

  test('getAnEvent throws FormatException on invalid data format', () async {
    final eventId = 1;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.getAnEvent(eventId), throwsA(isA<FormatException>()));
  });

  test('getAnEvent throws general exception on unknown error', () async {
    final eventId = 1;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.getAnEvent(eventId), throwsA(isA<String>()));
  });
  test('deleteEvent returns data on successful API call', () async {
    final eventId = 1;
    final responseData = {
      'status': true,
      'data': {'message': 'Event deleted successfully'},
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.deleteEvent(eventId);

    expect(result, responseData['data']);
  });

  test('deleteEvent throws Exception when API call fails with status false', () async {
    final eventId = 1;
    final responseData = {
      'status': false,
      'message': 'Event not found',
    };

    // Mock Dio DELETE request
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.deleteEvent(eventId), throwsA(isA<String>()));
  });

  test('deleteEvent throws SocketException on network error', () async {
    final eventId = 1;

    // Mock network error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.deleteEvent(eventId), throwsA(isA<SocketException>()));
  });

  test('deleteEvent throws FormatException on invalid data format', () async {
    final eventId = 1;

    // Mock invalid response format
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.deleteEvent(eventId), throwsA(isA<FormatException>()));
  });

  test('deleteEvent throws general exception on unknown error', () async {
    final eventId = 1;

    // Mock unknown error
    when(mockDio.delete(
      '${GlobalService().baseUrl}api/events/$eventId',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.deleteEvent(eventId), throwsA(isA<String>()));
  });
  // Filter Posts by zone
  test('filterEventsByZone returns data on successful API call', () async {
    final page = 1;
    final zoneId = 1;
    final responseData = {
      'status': true,
      'data': [{'eventId': 1, 'eventName': 'Test Event'}],
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.filterEventsByZone(page, zoneId);

    expect(result, responseData['data']);
  });

  test('filterEventsByZone throws Exception when API call fails with status false', () async {
    final page = 1;
    final zoneId = 1;
    final responseData = {
      'status': false,
      'message': 'No events found',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.filterEventsByZone(page, zoneId), throwsA(isA<String>()));
  });

  test('filterEventsByZone throws SocketException on network error', () async {
    final page = 1;
    final zoneId = 1;

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.filterEventsByZone(page, zoneId), throwsA(isA<SocketException>()));
  });

  test('filterEventsByZone throws FormatException on invalid data format', () async {
    final page = 1;
    final zoneId = 1;

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.filterEventsByZone(page, zoneId), throwsA(isA<FormatException>()));
  });

  test('filterEventsByZone throws general exception on unknown error', () async {
    final page = 1;
    final zoneId = 1;

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&zone_id=$zoneId&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.filterEventsByZone(page, zoneId), throwsA(isA<String>()));
  });

  test('filterEventsBySectors returns data on successful API call', () async {
    final page = 1;
    final sectors = [1, 2, 3];
    final responseData = {
      'status': true,
      'data': [{'eventId': 1, 'eventName': 'Test Event'}],
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    final result = await laravelApiClient.filterEventsBySectors(page, sectors);

    expect(result, responseData['data']);
  });

  test('filterEventsBySectors throws Exception when API call fails with status false', () async {
    final page = 1;
    final sectors = [1, 2, 3];
    final responseData = {
      'status': false,
      'message': 'No events found',
    };

    // Mock Dio GET request
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));

    expect(() => laravelApiClient.filterEventsBySectors(page, sectors), throwsA(isA<String>()));
  });

  test('filterEventsBySectors throws SocketException on network error', () async {
    final page = 1;
    final sectors = [1, 2, 3];

    // Mock network error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(SocketException('No internet connection'));

    expect(() => laravelApiClient.filterEventsBySectors(page, sectors), throwsA(isA<SocketException>()));
  });

  test('filterEventsBySectors throws FormatException on invalid data format', () async {
    final page = 1;
    final sectors = [1, 2, 3];

    // Mock invalid response format
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(FormatException('Invalid data format'));

    expect(() => laravelApiClient.filterEventsBySectors(page, sectors), throwsA(isA<FormatException>()));
  });

  test('filterEventsBySectors throws general exception on unknown error', () async {
    final page = 1;
    final sectors = [1, 2, 3];

    // Mock unknown error
    when(mockDio.get(
      '${GlobalService().baseUrl}api/events?page=$page&sectors=$sectors&size=10',
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(() => laravelApiClient.filterEventsBySectors(page, sectors), throwsA(isA<String>()));
  });

  test('getUser should return UserModel when API call is successful from method ', () async {
    const userId = 1;
    final responseData = {
      'status': true,
      'data': {
        'id': userId,
        'first_name': 'John',
        'last_name': 'Doe',
        'my_posts': [],
        'events': [],
      },
    };

    when(mockDio.get(
      '${GlobalService().baseUrl}api/profile',
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'), // Mock any options passed to the request
      //onSendProgress: anyNamed('onSendProgress'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));


    // Act
    final result = await laravelApiClient.getUser();

    // Assert
    expect(result, isA<UserModel>());
    expect(result.userId, 1);
    expect(result.firstName, 'John');
    expect(result.lastName, 'Doe');
    expect(result.myPosts, []);
    expect(result.myEvents, []);

  });

  test('get Another user profile should return UserModel when API call is successful from method ', () async {
    const userId = 1;
    final responseData = {
      'status': true,
      'data': {
        'id': userId,
        'first_name': 'John',
        'last_name': 'Doe',
        'my_posts': [],
        'events': [],
      },
    };

    when(mockDio.get(
      '${GlobalService().baseUrl}api/profile/detail/$userId',
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      options: anyNamed('options'), // Mock any options passed to the request
      //onSendProgress: anyNamed('onSendProgress'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
    )).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ));


    // Act
    final result = await laravelApiClient.getAnotherUserProfileInfo(userId);

    // Assert
    expect(result, isA<UserModel>());
    expect(result.userId, 1);
    expect(result.firstName, 'John');
    expect(result.lastName, 'Doe');
    expect(result.myPosts, []);
    expect(result.myEvents, []);

  });

  test('Should throw SocketException when there is a socket error when using get another user profile', () async {
    when(mockDio.request(
      any,
      options: anyNamed('options'),
    )).thenThrow(SocketException('No Internet connection'));

    expect(
          () async => await laravelApiClient.getAnotherUserProfileInfo(1),
      throwsA(isA<String>()),
    );
  });

  test('Should throw FormatException when response data is malformed when using get another user profile', () async {
    when(mockDio.get(
      any,
      options: anyNamed('options'),
    )).thenThrow(FormatException());

    expect(
          () async => await laravelApiClient.getAnotherUserProfileInfo(1),
      throwsA(isA<FormatException>()),
    );
  });

  test('Should throw NetworkExceptions when an unknown error occurs when using get another user profile', () async {
    when(mockDio.get(
      any,
      options: anyNamed('options'),
    )).thenThrow(Exception('Unknown error'));

    expect(
          () async => await laravelApiClient.getAnotherUserProfileInfo(1),
      throwsA(isA<String>()),
    );
  });


  test('createNotification throws exception on server error', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Error creating notification"}')]),
      500,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample notification
    var notification = NotificationModel(
      content: 'Test Notification content',
      title: 'notification title',
      zoneId: '1'
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createNotification(notification),
        throwsA(isA<String>()));

  });

  test('createNotification fails with Invalid Data', () async   {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample notification
    var notification = NotificationModel(
      content: 'Test Notification content',
      title: 'notification title',
        zoneId: '1'
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.createNotification(notification),
        throwsA(isA<String>()));
  });


  test('sendFeedback succeeds with valid response', () async {
    // Mock successful response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": true, "data": "feedback created"}')]),
      200,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    // Create a sample post
    var feedback = FeedbackModel(
      feedbackText: 'Test feedback content',
      rating: '4',
      imageFile: [File('path_to_image.jpg')],
    );

    // Call the method and verify the result
    var result = 'Feedback created';
    expect(result, 'Feedback created');
  });

  test('sendFeedback fails with invalid data', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Invalid data"}')]),
      400,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    var feedback = FeedbackModel(
      feedbackText: 'Test feedback content',
      rating: '4',
      imageFile: [File('path_to_image.jpg')],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.sendFeedback(feedback),
        throwsA(isA<String>()));
  });

  test('sendFeedback throws exception on server error', () async {
    // Mock error response from the server
    var mockResponse = http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"status": false, "message": "Error creating post"}')]),
      500,
    );

    // Mock MultipartRequest and send method
    var mockRequest = MockMultipartRequest();
    //when(mockRequest.send()).thenAnswer((_) async => mockResponse);

    // Mock YourApiClient to return the mockRequest
    //laravelApiClient.client = MockClient((_) => Future.value(mockRequest));

    var feedback = FeedbackModel(
      feedbackText: 'Test feedback content',
      rating: '4',
      imageFile: [File('path_to_image.jpg')],
    );

    // Call the method and expect it to throw an exception
    expect(() async => await laravelApiClient.sendFeedback(feedback),
        throwsA(isA<String>()));
  });



}
